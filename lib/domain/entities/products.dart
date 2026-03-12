class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.favorite = false,
  });

  // Método para criar uma cópia do produto com alguns campos modificados
  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? image,
    bool? favorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      favorite: favorite ?? this.favorite,
    );
  }
}
