class Product {
  String id;
  final String name;
  final int price;
  final int quantity;
  final List<String> imageUrls; // Danh sách URL hình ảnh
  String? category;
  String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrls,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrls': imageUrls, // Lưu danh sách URL hình ảnh
      'category': category,
      'description': description,
    };
  }
}
