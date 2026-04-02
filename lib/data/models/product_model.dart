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
      id: json["id"] is int ? json["id"] : int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"]?.toString() ?? '',
      price: json["price"] is num 
          ? (json["price"] as num).toDouble() 
          : double.tryParse(json["price"].toString()) ?? 0.0,
      image: json["image"]?.toString() ?? '',
      description: json["description"]?.toString() ?? '',
      category: json["category"]?.toString() ?? '',
      rating: (json["rating"] is Map) 
          ? Map<String, dynamic>.from(json["rating"]) 
          : {'rate': 0.0, 'count': 0},
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
