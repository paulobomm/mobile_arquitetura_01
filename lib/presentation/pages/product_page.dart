import 'package:flutter/material.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/presentation/product_viewmodel.dart';

class ProductPage extends StatefulWidget {
  final ProductViewModel viewModel;
  const ProductPage({super.key, required this.viewModel});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),

      body: ValueListenableBuilder<List<Product>>(
        valueListenable: widget.viewModel.products,
        builder: (context, products, _) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.image),
                title: Text(product.title),
                subtitle: Text("\$${product.price}"),
              );
            },
          );
        },
      ),
    );
  }
}
