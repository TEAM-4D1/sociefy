import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/models/society.dart';

void main() {
  test('Society.fromMap parses valid map', () {
    final map = {
      'id': 's1',
      'name': 'Chess Club',
      'category': 'Sports',
      'description': 'We play chess',
    };

    final society = Society.fromMap(map);

    expect(society.id, 's1');
    expect(society.name, 'Chess Club');
    expect(society.category, 'Sports');
    expect(society.description, 'We play chess');
  });

  test('Society.fromMap handles missing keys gracefully', () {
    final map = {
      'name': 'Drama Society',
    };

    final society = Society.fromMap(map, id: 'generated-id');

    expect(society.id, 'generated-id');
    expect(society.name, 'Drama Society');
    expect(society.category, '');
    expect(society.description, '');
  });
}
