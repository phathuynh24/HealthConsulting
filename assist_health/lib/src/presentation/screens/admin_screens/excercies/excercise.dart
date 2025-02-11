class Exercise {
  String id;
  String name;
  double calories;
  String description;
  int duration;
  String imageUrl;
  String youtubeUrl;
  List<String> types;

  Exercise({
    required this.id,
    required this.name,
    required this.calories,
    required this.description,
    required this.duration,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.types,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'description': description,
      'duration': duration,
      'imageUrl': imageUrl,
      'youtubeUrl': youtubeUrl,
      'types': types,
    };
  }

  factory Exercise.fromMap(String id, Map<String, dynamic> data) {
    return Exercise(
      id: id,
      name: data['name'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      types: (data['types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
