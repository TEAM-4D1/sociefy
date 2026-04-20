class Society {
  final String id;
  final String name;
  final String description;
  final String category;
  final String contactEmail;
  final String contactName;
  final int memberCount;
  final bool isJoined;

  Society({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.contactEmail,
    required this.contactName,
    required this.memberCount,
    required this.isJoined,
  });

  Society copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? contactEmail,
    String? contactName,
    int? memberCount,
    bool? isJoined,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      contactEmail: contactEmail ?? this.contactEmail,
      contactName: contactName ?? this.contactName,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
