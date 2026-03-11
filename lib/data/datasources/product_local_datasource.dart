import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/data/models/product model.dart';

class ProductLocalDataSource {
  static const String _cacheKey = 'cached_products';

  Future<void> saveProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('No cached data found');
    }
  }
}
