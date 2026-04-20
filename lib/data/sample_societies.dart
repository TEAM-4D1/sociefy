class Society {
  final String id;
  final String name;
  final String description;
  final String category;
  final String contactName;
  final String contactEmail;
  final int memberCount;
  final bool isJoined;

  Society({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.contactName,
    required this.contactEmail,
    required this.memberCount,
    required this.isJoined,
  });

  Society copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? contactName,
    String? contactEmail,
    int? memberCount,
    bool? isJoined,
  }) {
    return Society(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
