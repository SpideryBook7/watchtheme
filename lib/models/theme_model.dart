class ThemeModel {
  final String id;
  final String name;
  final String description;
  final List<String> categories;
  final String imageUrl;

  ThemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.imageUrl,
  });

  factory ThemeModel.fromMap(Map<String, dynamic> data) {
    return ThemeModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories,
      'imageUrl': imageUrl,
    };
  }
}
