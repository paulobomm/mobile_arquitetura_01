import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/presentation/providers/product_providers.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _imageController = TextEditingController(text: widget.product?.image ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      
      final product = Product(
        id: widget.product?.id ?? 0,
        title: _titleController.text,
        price: price,
        image: _imageController.text.isNotEmpty ? _imageController.text : 'https://placehold.co/400',
        description: _descriptionController.text,
        category: _categoryController.text.isNotEmpty ? _categoryController.text : 'Geral',
        rating: widget.product?.rating ?? ProductRating(rate: 0, count: 0),
        favorite: widget.product?.favorite ?? false,
      );

      if (widget.product == null) {
        ref.read(productsProvider.notifier).addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto adicionado com sucesso localmente!')),
        );
      } else {
        ref.read(productsProvider.notifier).updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto editado com sucesso localmente!')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o título do produto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o preço do produto.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor numérico válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem',
                  border: OutlineInputBorder(),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.save),
                label: const Text('SALVAR PRODUTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
