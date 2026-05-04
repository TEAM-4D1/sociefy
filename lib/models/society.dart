import 'committee_member.dart';

class Society {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<CommitteeMember> committeeMembers;

  Society({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.committeeMembers = const [],
  });

  Society copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    List<CommitteeMember>? committeeMembers,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      committeeMembers: committeeMembers ?? this.committeeMembers,
    );
  }
}
