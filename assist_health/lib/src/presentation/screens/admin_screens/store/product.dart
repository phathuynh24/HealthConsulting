class Product {
  String id;
  final String name;
  final int price;
  final int oldPrice;
  final int quantity;
  final List<String> imageUrls; // Danh sách URL hình ảnh
  String? category;
  String? description;
  double rating;
  int voteCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.quantity,
    required this.imageUrls,
    required this.category,
    this.description,
    this.rating = 0.0,
    this.voteCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'old_price': oldPrice,
      'quantity': quantity,
      'imageUrls': imageUrls, // Lưu danh sách URL hình ảnh
      'category': category,
      'description': description,
      'rating': rating, // Add this line
      'voteCount': voteCount,
    };
  }
}
