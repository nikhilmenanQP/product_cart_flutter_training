import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  final ValueNotifier<int> cartCountNotifier;
  const CartScreen({super.key, required this.cartCountNotifier});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _addCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final now = DateTime.now();
    final date = now.toIso8601String().split('T').first;
    final body = json.encode({
      'userId': userId,
      'date': date,
      'products': [
        {'productId': productId, 'quantity': quantity},
      ],
    });
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/carts'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint('AddCart response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cart added successfully!')),
          );
          await _fetchCarts();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add cart: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('CartScreen is being built');
  }

  List<dynamic> _carts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCarts();
  }

  Future<void> _fetchCarts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/carts'),
      );
      debugPrint('GetAllCarts response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final carts = json.decode(response.body);
        setState(() {
          _carts = carts;
          _loading = false;
        });
        // Update cart count notifier
        int productCount = 0;
        for (final cart in carts) {
          if (cart['products'] is List) {
            productCount += (cart['products'] as List).length;
          }
        }
        widget.cartCountNotifier.value = productCount;
        debugPrint('Cart count after refresh: ${_carts.length}');
      } else {
        setState(() {
          _error = 'Failed to load carts';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart List')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                itemCount: _carts.length,
                itemBuilder: (context, index) {
                  final cart = _carts[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Cart ID: ${cart['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${cart['userId']}'),
                          Text('Date: ${cart['date']}'),
                          Text('Products: ${cart['products'].length}'),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Cart ${cart['id']} Products'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        (cart['products'] as List).length,
                                    itemBuilder: (context, idx) {
                                      final product = cart['products'][idx];
                                      return ListTile(
                                        title: Text(
                                          'Product ID: ${product['productId']}',
                                        ),
                                        subtitle: Text(
                                          'Quantity: ${product['quantity']}',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          int userId = 1;
          int productId = 1;
          int quantity = 1;
          final userIdController = TextEditingController(
            text: userId.toString(),
          );
          final productIdController = TextEditingController(
            text: productId.toString(),
          );
          final quantityController = TextEditingController(
            text: quantity.toString(),
          );
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Add Cart'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: userIdController,
                        decoration: const InputDecoration(labelText: 'User ID'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: productIdController,
                        decoration: const InputDecoration(
                          labelText: 'Product ID',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          );
          if (result == true) {
            final uid = int.tryParse(userIdController.text) ?? 1;
            final pid = int.tryParse(productIdController.text) ?? 1;
            final qty = int.tryParse(quantityController.text) ?? 1;
            await _addCart(userId: uid, productId: pid, quantity: qty);
            // After adding, refresh cart count
            await _fetchCarts();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Cart',
      ),
    );
  }
}
