import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<Product>> getProducts() async {
    final models = await dataSource.getProducts();

    return models
        .map(
          (m) =>
              Product(id: m.id, title: m.title, price: m.price, image: m.image),
        )
        .toList();
  }
}
