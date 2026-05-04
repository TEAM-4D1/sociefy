/// Represents a student society within the university application.
///
/// A `Society` groups students around a shared interest, academic subject,
/// or extracurricular activity. Instances of this class are used throughout
/// the app to display society listings, show details on society profile
/// screens, and associate events or messages with a particular society.
class Society {
  /// Unique identifier for the society.
  ///
  /// This is typically the Firestore document ID or other backend-generated
  /// key used to reference the society record. Use this to perform updates
  /// or to fetch related resources (events, members, messages).
  final String id;

  /// Human-readable name of the society.
  ///
  /// Example: "Computer Science Society", "Dance Collective". Display this
  /// value in lists, headers, and search results where the society is shown.
  final String name;

  /// Category or type of the society.
  ///
  /// Represents a broad classification such as "Academic", "Sports",
  /// "Arts", or a faculty/department tag. This helps with filtering and
  /// organizing societies in the UI.
  final String category;

  /// Short description summarizing the society's purpose and activities.
  ///
  /// Displayed on society profile pages and in preview cards to give users
  /// a quick overview of what the society does and who it's for.
  final String description;

  /// Constructs a new immutable `Society`.
  Society({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  /// Returns a copy of this `Society` with the given fields replaced.
  ///
  /// Useful for immutable updates when only a subset of properties need
  /// to change (for example, updating the `description` without modifying
  /// other fields).
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
