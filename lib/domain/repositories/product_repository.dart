import 'package:product_app/domain/entities/products.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
