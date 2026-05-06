class Society {
  final String id;
  final String name;
  final String description;
  final String category;
  final String contactName;
  final String contactEmail;
  final int memberCount;
  final bool isJoined;

  const Society({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.contactName = '',
    this.contactEmail = '',
    this.memberCount = 0,
    this.isJoined = false,
  });
}

const List<Society> sampleSocieties = [
  Society(
    id: 'soc1',
    name: 'Chess Club',
    description:
        'For chess lovers of all skill levels. Weekly games and tournaments.',
    category: 'Games',
  ),
  Society(
    id: 'soc2',
    name: 'Photography Society',
    description:
        'Explore the art of photography with workshops and photo walks.',
    category: 'Arts',
  ),
  Society(
    id: 'soc3',
    name: 'Coding Society',
    description: 'Join us for hackathons, coding challenges, and tech talks.',
    category: 'Technology',
  ),
  Society(
    id: 'soc4',
    name: 'Drama Club',
    description: 'Act, direct, or help backstage in our student productions.',
    category: 'Performing Arts',
  ),
  Society(
    id: 'soc5',
    name: 'Environmental Society',
    description:
        'Make a difference with sustainability projects and campaigns.',
    category: 'Environment',
  ),
];
