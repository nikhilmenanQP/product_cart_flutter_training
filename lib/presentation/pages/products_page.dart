import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/product_usecases.dart';

class ProductsPage extends StatefulWidget {
  final ValueNotifier<int> cartCountNotifier;
  const ProductsPage({super.key, required this.cartCountNotifier});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Track product IDs in the cart
  Set<int> _cartProductIds = {};

  Future<void> _loadCartProductIds() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/carts'),
      );
      if (response.statusCode == 200) {
        final carts = json.decode(response.body) as List;
        final ids = <int>{};
        for (final cart in carts) {
          for (final prod in cart['products']) {
            ids.add(prod['productId'] as int);
          }
        }
        setState(() {
          _cartProductIds = ids;
        });
        widget.cartCountNotifier.value = ids.length;
      }
    } catch (_) {}
  }

  Future<void> _addToCart(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/carts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 1, // You may want to use a real userId
          'date': DateTime.now().toIso8601String().split('T').first,
          'products': [
            {'productId': product.id, 'quantity': 1},
          ],
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added to cart!')),
          );
        }
        // Always reload cart list after adding to cart
        await _loadCartProductIds();
        if (mounted) setState(() {}); // Ensure UI updates everywhere
      } else {
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _removeFromCart(Product product) async {
    try {
      // For demo: remove the cart with userId=1 (since fakestoreapi doesn't support removing a single product from a cart)
      // In real app, you'd want to remove the product from the cart, not the whole cart.
      final response = await http.delete(
        Uri.parse('https://fakestoreapi.com/carts/1'),
      );
      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product removed from cart!')),
          );
        }
        await _loadCartProductIds();
      } else {
        throw Exception('Failed to remove from cart');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  final _repo = ProductRepositoryImpl();
  late final GetProductsUseCase _getProducts = GetProductsUseCase(_repo);
  late final AddProductUseCase _addProduct = AddProductUseCase(_repo);
  late final DeleteProductUseCase _deleteProduct = DeleteProductUseCase(_repo);
  late final EditProductUseCase _editProduct = EditProductUseCase(_repo);

  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartProductIds();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    _products = await _getProducts();
    setState(() => _loading = false);
  }

  Future<void> _showProductDialog({Product? product}) async {
    final titleController = TextEditingController(text: product?.title ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final categoryController = TextEditingController(
      text: product?.category ?? '',
    );
    final imageController = TextEditingController(text: product?.image ?? '');
    final isEdit = product != null;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? 'Edit Product' : 'Add Product'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Removed debug print for cleaner production code
                  final title = titleController.text.trim();
                  final price =
                      double.tryParse(priceController.text.trim()) ?? 0.0;
                  final description =
                      descriptionController.text.trim().isNotEmpty
                          ? descriptionController.text.trim()
                          : '';
                  final category =
                      categoryController.text.trim().isNotEmpty
                          ? categoryController.text.trim()
                          : '';
                  final image =
                      imageController.text.trim().isNotEmpty
                          ? imageController.text.trim()
                          : '';
                  if (title.isEmpty || price <= 0) return;
                  bool success = false;
                  String message = '';
                  try {
                    if (isEdit) {
                      final updatedProduct = Product(
                        id: product.id,
                        title: title,
                        price: price,
                        description: description,
                        category: category,
                        image: image,
                      );
                      await _editProduct(updatedProduct);
                      setState(() {
                        final idx = _products.indexWhere(
                          (p) => p.id == updatedProduct.id,
                        );
                        if (idx != -1) {
                          _products[idx] = updatedProduct;
                        }
                      });
                      success = true;
                      message = 'Product updated successfully.';
                    } else {
                      // Use the AddProductUseCase to add product
                      final newProduct = Product(
                        id: 0, // id will be set by API or backend
                        title: title,
                        price: price,
                        description: description,
                        category: category,
                        image: image,
                      );
                      await _addProduct(newProduct);
                      await _loadProducts();
                      success = true;
                      message = 'Product added successfully.';
                    }
                  } catch (e) {
                    message = 'Failed to add/edit product.';
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProductById(int id) async {
    try {
      await _deleteProduct(id);
      setState(() {
        _products.removeWhere((p) => p.id == id);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete product.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Product',
                onPressed: () => _showProductDialog(),
              ),
            ],
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: Column(
            children: [
              // Optionally, you can keep some top spacing if you want:
              // SizedBox(height: MediaQuery.of(context).padding.top + 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    String imageUrl =
                        product.image.isNotEmpty
                            ? product.image
                            : 'https://picsum.photos/seed/${product.id}/300/400';
                    final inCart = _cartProductIds.contains(product.id);
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.18),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (product.category.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  product.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 22),
                                  onPressed:
                                      () =>
                                          _showProductDialog(product: product),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 22),
                                  onPressed:
                                      () => _deleteProductById(product.id),
                                  tooltip: 'Delete',
                                ),
                                StatefulBuilder(
                                  builder: (context, setStateIcon) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.shopping_bag,
                                        color:
                                            inCart ? Colors.green : Colors.grey,
                                        size: 24,
                                      ),
                                      tooltip:
                                          inCart
                                              ? 'Remove from Cart'
                                              : 'Add to Cart',
                                      onPressed: () async {
                                        if (!inCart) {
                                          await _addToCart(product);
                                        } else {
                                          await _removeFromCart(product);
                                        }
                                        if (mounted) setStateIcon(() {});
                                        if (mounted) setState(() {});
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
  }
}
