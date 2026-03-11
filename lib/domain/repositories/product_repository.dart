import 'package:product_app/domain/entities/products.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
