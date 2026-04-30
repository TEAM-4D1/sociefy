class Society {
  final String id;
  final String name;
  final String category;
  final String description;

  Society({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  Society copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
