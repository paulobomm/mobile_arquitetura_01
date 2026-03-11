import 'package:flutter/foundation.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/presentation/product_state.dart';

class ProductViewModel {
  final ProductRepository repository;

  final ValueNotifier<ProductState> state = ValueNotifier(ProductInitial());

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    state.value = ProductLoading();
    try {
      final result = await repository.getProducts();
      state.value = ProductLoaded(result);
    } catch (e) {
      state.value = ProductError(e.toString());
    }
  }
}
