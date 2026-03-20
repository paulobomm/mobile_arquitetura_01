class ProductModel {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  final Map<String, dynamic> rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"],
      title: json["title"],
      price: json["price"].toDouble(),
      image: json["image"],
      description: json["description"] ?? '',
      category: json["category"] ?? '',
      rating: json["rating"] ?? {'rate': 0.0, 'count': 0},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "image": image,
      "description": description,
      "category": category,
      "rating": rating,
    };
  }
}
