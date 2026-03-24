class Product {
  final int productId;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final int? quantity;
  final bool isAvailable;

  Product({
    required this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.quantity,
    required this.isAvailable,
  });

  bool get isInStock => isAvailable && (quantity ?? 0) > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is String)
          ? double.parse(json['price'])
          : (json['price'] ?? 0).toDouble(),
      categoryId: json['category_id'] ?? 0,
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}
