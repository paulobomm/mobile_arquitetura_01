import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/presentation/providers/auth_provider.dart';
import 'package:product_app/presentation/providers/product_providers.dart';
import 'package:product_app/presentation/widgets/logout_button.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final favoriteCount = ref.watch(favoriteCountProvider);
    final showOnlyFavorites = ref.watch(filterFavoritesProvider);
    final authUser = ref.watch(authProvider).user;

    final productCount = filteredProductsAsync.when(
      data: (products) => products.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        leading: authUser != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _UserAvatar(user: authUser),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        authUser.firstName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        title: Text("Produtos ($productCount)"),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar produtos',
            onPressed: () => ref.read(productsProvider.notifier).loadProducts(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
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
          const LogoutButton(),
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
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: product,
                  );
                },
                onFavoriteTap: () {
                  ref
                      .read(productsProvider.notifier)
                      .toggleFavorite(product.id ?? 0);
                },
                onEdit: () {
                  Navigator.pushNamed(
                    context,
                    '/form',
                    arguments: product,
                  );
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir Produto'),
                      content: Text('Deseja realmente excluir "${product.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(productsProvider.notifier).removeProduct(product.id ?? 0);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/form');
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.onFavoriteTap,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: product.favorite ? Colors.amber.withValues(alpha: 0.15) : null,
      elevation: product.favorite ? 4 : 1,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: product.favorite
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    color: Colors.amber.withValues(alpha: 0.7),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
            IconButton(
              icon: Icon(
                product.favorite ? Icons.star : Icons.star_border,
                color: product.favorite ? Colors.amber : Colors.grey,
                size: 28,
              ),
              onPressed: onFavoriteTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatefulWidget {
  final dynamic user;
  const _UserAvatar({required this.user});

  @override
  State<_UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<_UserAvatar> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.deepPurple,
      backgroundImage: (!_imageError && widget.user.image.isNotEmpty)
          ? NetworkImage(widget.user.image)
          : null,
      onBackgroundImageError: (!_imageError && widget.user.image.isNotEmpty)
          ? (_, __) => setState(() => _imageError = true)
          : null,
      child: (_imageError || widget.user.image.isEmpty)
          ? Text(
              widget.user.firstName.isNotEmpty
                  ? widget.user.firstName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
