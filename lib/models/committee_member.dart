class CommitteeMember {
  String name;
  String role;
  String email;

  CommitteeMember({
    required this.name,
    required this.role,
    required this.email,
  });

  factory CommitteeMember.fromMap(Map<String, dynamic> map) {
    return CommitteeMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role, 'email': email};
  }
}
