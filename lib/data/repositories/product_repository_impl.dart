import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_local_datasource.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remoteDataSource.getProducts();
      await localDataSource.saveProducts(models);

      return models
          .map(
            (m) => Product(
              id: m.id,
              title: m.title,
              price: m.price,
              image: m.image,
            ),
          )
          .toList();
    } catch (e) {
      try {
        final localModels = await localDataSource.getCachedProducts();
        return localModels
            .map(
              (m) => Product(
                id: m.id,
                title: m.title,
                price: m.price,
                image: m.image,
              ),
            )
            .toList();
      } catch (cacheError) {
        throw Exception(
          'Failed to load products: Network error and no local cache available',
        );
      }
    }
  }
}
