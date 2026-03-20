class ProductRating {
  final double rate;
  final int count;

  ProductRating({required this.rate, required this.count});
}

class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  final ProductRating rating;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
    this.favorite = false,
  });

  
  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? image,
    String? description,
    String? category,
    ProductRating? rating,
    bool? favorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
    );
  }
}
