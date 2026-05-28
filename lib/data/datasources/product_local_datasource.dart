import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/data/models/product_model.dart';

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

  Future<ProductModel> addProduct(ProductModel product) async {
    final products = await _safeGetCachedProducts();
    
    final newId = products.isEmpty ? 1 : products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final newProduct = ProductModel(
      id: newId,
      title: product.title,
      price: product.price,
      thumbnail: product.thumbnail,
      description: product.description,
      category: product.category,
      rating: product.rating,
    );
    
    products.add(newProduct);
    await saveProducts(products);
    return newProduct;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final products = await _safeGetCachedProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    
    if (index != -1) {
      products[index] = product;
      await saveProducts(products);
      return product;
    } else {
      throw Exception('Produto não encontrado no cache para edição');
    }
  }

  Future<void> removeProduct(int id) async {
    final products = await _safeGetCachedProducts();
    products.removeWhere((p) => p.id == id);
    await saveProducts(products);
  }

  Future<List<ProductModel>> _safeGetCachedProducts() async {
    try {
      return await getCachedProducts();
    } catch (_) {
      return [];
    }
  }
}

