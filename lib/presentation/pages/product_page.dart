import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/presentation/providers/product_providers.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final favoriteCount = ref.watch(favoriteCountProvider);
    final showOnlyFavorites = ref.watch(filterFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produtos"),
        elevation: 2,
        actions: [
          // Contador de favoritos
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$favoriteCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botão de filtro
          IconButton(
            icon: Icon(
              showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: showOnlyFavorites ? Colors.red : null,
            ),
            tooltip: showOnlyFavorites
                ? 'Mostrar todos os produtos'
                : 'Mostrar apenas favoritos',
            onPressed: () {
              ref.read(filterFavoritesProvider.notifier).toggleFilter();
            },
          ),
        ],
      ),
      body: filteredProductsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(
                showOnlyFavorites
                    ? 'Nenhum produto favoritado.'
                    : 'Nenhum produto disponível.',
              ),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductTile(
                product: product,
                onFavoriteTap: () {
                  ref
                      .read(productsProvider.notifier)
                      .toggleFavorite(product.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar produtos:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(productsProvider);
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // Destaque visual para favoritos
      color: product.favorite ? Colors.amber.withOpacity(0.15) : Colors.white,
      elevation: product.favorite ? 4 : 1,
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Borda destacada para favoritos
            border: product.favorite
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  // Destaque no texto para favoritos
                  color: product.favorite ? Colors.deepPurple : null,
                ),
              ),
            ),
            if (product.favorite)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Favorito',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'R\$ ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            product.favorite ? Icons.star : Icons.star_border,
            color: product.favorite ? Colors.amber : Colors.grey,
            size: 28,
          ),
          onPressed: onFavoriteTap,
        ),
      ),
    );
  }
}
