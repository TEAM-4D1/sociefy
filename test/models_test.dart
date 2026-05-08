import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/models/announcement.dart';
import 'package:sociefy/models/committee_member.dart';
import 'package:sociefy/models/event.dart';
import 'package:sociefy/models/society.dart';

/// Pure-Dart tests for the domain model classes. These hit construction,
/// serialisation, and the small amount of behaviour each model carries.
void main() {
  group('CommitteeMember', () {
    test('fromMap reads all three fields', () {
      final m = CommitteeMember.fromMap({
        'name': 'Alex',
        'role': 'Chair',
        'email': 'alex@example.com',
      });
      expect(m.name, 'Alex');
      expect(m.role, 'Chair');
      expect(m.email, 'alex@example.com');
    });

    test('fromMap defaults missing fields to empty string', () {
      final m = CommitteeMember.fromMap({});
      expect(m.name, '');
      expect(m.role, '');
      expect(m.email, '');
    });

    test('toMap round-trips through fromMap', () {
      final m1 = CommitteeMember(
        name: 'Alex',
        role: 'Chair',
        email: 'alex@example.com',
      );
      final m2 = CommitteeMember.fromMap(m1.toMap());
      expect(m2.name, m1.name);
      expect(m2.role, m1.role);
      expect(m2.email, m1.email);
    });
  });

  group('Society', () {
    test('fromMap reads all four fields', () {
      final s = Society.fromMap({
        'id': 'sA',
        'name': 'Chess',
        'category': 'Games',
        'description': 'Strategy',
      });
      expect(s.id, 'sA');
      expect(s.name, 'Chess');
      expect(s.category, 'Games');
      expect(s.description, 'Strategy');
    });

    test('fromMap respects explicit id override', () {
      final s = Society.fromMap(
        {'id': 'ignored', 'name': 'Chess'},
        id: 'override',
      );
      expect(s.id, 'override');
    });

    test('copyWith replaces only the named fields', () {
      final s1 = Society(
        id: 'sA',
        name: 'Chess',
        category: 'Games',
        description: 'd1',
      );
      final s2 = s1.copyWith(description: 'd2');
      expect(s2.id, 'sA');
      expect(s2.name, 'Chess');
      expect(s2.description, 'd2');
    });

    test('copyWith with no args returns an equivalent instance', () {
      final s1 = Society(
        id: 'sA',
        name: 'Chess',
        category: 'Games',
        description: 'd',
      );
      final s2 = s1.copyWith();
      expect(s2.id, s1.id);
      expect(s2.name, s1.name);
      expect(s2.category, s1.category);
      expect(s2.description, s1.description);
    });
  });

  group('Event', () {
    test('constructor stores all required fields', () {
      final e = Event(
        id: 'e1',
        societyId: 'sA',
        societyName: 'Chess',
        title: 'Meetup',
        description: 'Casual play',
        date: DateTime(2026, 5, 1),
        startTime: '10:00',
        endTime: '12:00',
        venue: 'Hall',
        isSaved: false,
      );
      expect(e.id, 'e1');
      expect(e.title, 'Meetup');
      expect(e.venue, 'Hall');
      expect(e.isSaved, isFalse);
    });
  });

  group('Comment', () {
    test('fromFirestore parses Timestamp dateTime', () {
      final ts = Timestamp.fromDate(DateTime(2026, 5, 1, 10, 30));
      final c = Comment.fromFirestore(
        {'author': 'Alex', 'content': 'Hi', 'dateTime': ts},
        'doc1',
      );
      expect(c.id, 'doc1');
      expect(c.author, 'Alex');
      expect(c.dateTime.year, 2026);
    });

    test('fromFirestore parses millisecondsSinceEpoch dateTime', () {
      final ms = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      final c = Comment.fromFirestore(
        {'author': 'Alex', 'content': 'Hi', 'dateTime': ms},
        'doc2',
      );
      expect(c.dateTime.year, 2026);
    });

    test('fromFirestore parses raw DateTime dateTime', () {
      final dt = DateTime(2026, 6, 15);
      final c = Comment.fromFirestore(
        {'author': 'Alex', 'content': 'Hi', 'dateTime': dt},
        'doc3',
      );
      expect(c.dateTime, dt);
    });

    test('fromFirestore falls back to now() for missing dateTime', () {
      final before = DateTime.now();
      final c = Comment.fromFirestore(
        {'author': 'Alex', 'content': 'Hi'},
        'doc4',
      );
      final after = DateTime.now();
      expect(
        c.dateTime.isAfter(before.subtract(const Duration(seconds: 1))) &&
            c.dateTime.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('fromFirestore defaults missing author/content to sentinels', () {
      final c = Comment.fromFirestore({}, 'doc5');
      expect(c.author, 'Unknown');
      expect(c.content, '');
    });
  });

  group('Announcement', () {
    Announcement build({TimeOfDay? time, String? venue}) => Announcement(
          id: 'a1',
          societyId: 'sA',
          title: 'Hi',
          content: 'world',
          date: DateTime(2026, 3, 5),
          time: time,
          venue: venue,
        );

    test('toggleLike adds and removes a userId', () {
      final a = build();
      a.toggleLike('u1');
      expect(a.likedBy, contains('u1'));
      expect(a.likeCount, 1);
      a.toggleLike('u1');
      expect(a.likedBy, isNot(contains('u1')));
      expect(a.likeCount, 0);
    });

    test('isLikedByUser returns false when userId is null', () {
      final a = build();
      a.toggleLike('u1');
      expect(a.isLikedByUser(null), isFalse);
      expect(a.isLikedByUser('u1'), isTrue);
      expect(a.isLikedByUser('u2'), isFalse);
    });

    test('addComment appends a Comment with the given author and content', () {
      final a = build();
      a.addComment('Alex', 'First!');
      expect(a.comments, hasLength(1));
      expect(a.comments.first.author, 'Alex');
      expect(a.comments.first.content, 'First!');
    });

    test('dateTimeVenueString returns null when time or venue is null', () {
      expect(build(venue: 'Hall').dateTimeVenueString, isNull);
      expect(
        build(time: const TimeOfDay(hour: 9, minute: 30)).dateTimeVenueString,
        isNull,
      );
    });

    test('dateTimeVenueString formats AM time with zero-padded date', () {
      final a = build(
        time: const TimeOfDay(hour: 9, minute: 5),
        venue: 'Library',
      );
      expect(a.dateTimeVenueString, '2026-03-05, 09:05 AM @ Library');
    });

    test('dateTimeVenueString formats PM time correctly', () {
      final a = build(
        time: const TimeOfDay(hour: 14, minute: 45),
        venue: 'Hall',
      );
      expect(a.dateTimeVenueString, '2026-03-05, 02:45 PM @ Hall');
    });

    test('dateTimeVenueString handles noon (PM, hourOfPeriod 12)', () {
      final a = build(
        time: const TimeOfDay(hour: 12, minute: 0),
        venue: 'A',
      );
      expect(a.dateTimeVenueString, contains('12:00 PM'));
    });

    test('dateTimeVenueString handles midnight (AM, hourOfPeriod 12)', () {
      final a = build(
        time: const TimeOfDay(hour: 0, minute: 0),
        venue: 'A',
      );
      expect(a.dateTimeVenueString, contains('12:00 AM'));
    });
  });
}
