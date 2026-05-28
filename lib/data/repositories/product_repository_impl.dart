import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_local_datasource.dart';
import 'package:product_app/data/models/product_model.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/domain/repositories/product_repository.dart';

Product _fromModel(ProductModel m) => Product(
  id: m.id,
  title: m.title,
  price: m.price,
  image: m.thumbnail,
  description: m.description,
  category: m.category,
  rating: ProductRating(rate: m.rating, count: 0),
);

ProductModel _toModel(Product p) => ProductModel(
  id: p.id ?? 0,
  title: p.title,
  price: p.price,
  thumbnail: p.image,
  description: p.description,
  category: p.category,
  rating: p.rating.rate,
);

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remoteDataSource.getProducts();
      await localDataSource.saveProducts(models);
      return models.map(_fromModel).toList();
    } catch (e) {
      try {
        final localModels = await localDataSource.getCachedProducts();
        return localModels.map(_fromModel).toList();
      } catch (cacheError) {
        throw Exception(
          'Falha ao carregar produtos: sem rede e sem cache disponível',
        );
      }
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final saved = await localDataSource.addProduct(_toModel(product));
    return _fromModel(saved);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final updated = await localDataSource.updateProduct(_toModel(product));
    return _fromModel(updated);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await localDataSource.removeProduct(id);
  }
}
