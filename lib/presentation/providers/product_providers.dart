import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_local_datasource.dart';
import 'dart:io';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = HttpClient();
  final remoteDataSource = ProductRemoteDataSource(client);
  final localDataSource = ProductLocalDataSource();
  return ProductRepositoryImpl(remoteDataSource, localDataSource);
});

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
      final repository = ref.watch(productRepositoryProvider);
      return ProductsNotifier(repository);
    });

final favoriteCountProvider = Provider<int>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.when(
    data: (products) => products.where((p) => p.favorite).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final favoriteProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.when(
    data: (products) => products.where((p) => p.favorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final filterFavoritesProvider = StateNotifierProvider<FilterNotifier, bool>((
  ref,
) {
  return FilterNotifier();
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final showOnlyFavorites = ref.watch(filterFavoritesProvider);

  return productsAsync.when(
    data: (products) {
      final filtered = showOnlyFavorites
          ? products.where((p) => p.favorite).toList()
          : products;
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class FilterNotifier extends StateNotifier<bool> {
  FilterNotifier() : super(false);

  void toggleFilter() {
    state = !state;
  }

  void reset() {
    state = false;
  }
}

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository repository;

  ProductsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await repository.getProducts();
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final currentState = state;

    if (currentState is! AsyncData<List<Product>>) return;

    final products = currentState.value;
    final productIndex = products.indexWhere((p) => p.id == productId);

    if (productIndex == -1) return;

    try {
      final updatedProducts = [...products];
      updatedProducts[productIndex] = updatedProducts[productIndex].copyWith(
        favorite: !updatedProducts[productIndex].favorite,
      );

      state = AsyncValue.data(updatedProducts);

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsFavorite(int productId) async {
    final currentState = state;

    if (currentState is! AsyncData<List<Product>>) return;

    final products = currentState.value;
    final productIndex = products.indexWhere((p) => p.id == productId);

    if (productIndex == -1 || products[productIndex].favorite) return;

    try {
      final updatedProducts = [...products];
      updatedProducts[productIndex] = updatedProducts[productIndex].copyWith(
        favorite: true,
      );
      state = AsyncValue.data(updatedProducts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    final currentState = state;

    if (currentState is! AsyncData<List<Product>>) return;

    final products = currentState.value;
    final productIndex = products.indexWhere((p) => p.id == productId);

    if (productIndex == -1 || !products[productIndex].favorite) return;

    try {
      final updatedProducts = [...products];
      updatedProducts[productIndex] = updatedProducts[productIndex].copyWith(
        favorite: false,
      );
      state = AsyncValue.data(updatedProducts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await repository.createProduct(product);
      if (state is AsyncData) {
        final products = state.value!;
        state = AsyncValue.data([newProduct, ...products]);
      } else {
        await loadProducts();
      }
    } catch (e) {
      // Ignorar erros visuais pro app mockado por agora
      print("Erro ao adicionar produto: $e");
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final updatedProduct = await repository.updateProduct(product);
      if (state is AsyncData) {
        final products = state.value!;
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          final updatedList = [...products];
          updatedList[index] = updatedProduct;
          state = AsyncValue.data(updatedList);
        }
      }
    } catch (e) {
      print("Erro ao atualizar produto: $e");
    }
  }

  Future<void> removeProduct(int productId) async {
    try {
      await repository.deleteProduct(productId);
      if (state is AsyncData) {
        final products = state.value!;
        final updatedList = products.where((p) => p.id != productId).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      print("Erro ao remover produto: $e");
    }
  }
}
