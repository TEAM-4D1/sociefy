class Society {
  final String id;
  final String name;
  final String category;
  final String description;
  final bool isJoined;

  Society({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.isJoined = false,
  });

  Society copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    bool? isJoined,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
