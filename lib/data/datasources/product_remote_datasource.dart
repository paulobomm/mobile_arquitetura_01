import 'dart:convert';
import 'dart:io' show HttpClient;

import 'package:product_app/data/models/product_model.dart';

class ProductRemoteDataSource {
  final HttpClient client;

  ProductRemoteDataSource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final request = await client.getUrl(
      Uri.parse("https://fakestoreapi.com/products"),
    );
    final response = await request.close();
    final data = await response.transform(utf8.decoder).join();
    final jsonData = jsonDecode(data);

    return (jsonData as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
