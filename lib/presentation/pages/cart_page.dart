import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartProducts();
  }

  Future<void> _fetchCartProducts() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/carts'),
      );
      if (response.statusCode == 200) {
        final carts = json.decode(response.body) as List;
        final List<Map<String, dynamic>> products = [];
        for (final cart in carts) {
          for (final prod in cart['products']) {
            products.add({
              'productId': prod['productId'],
              'quantity': prod['quantity'],
              'cartId': cart['id'],
              'userId': cart['userId'],
              'date': cart['date'],
            });
          }
        }
        setState(() {
          _cartProducts = products;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _cartProducts.isEmpty
              ? const Center(child: Text('No products in cart.'))
              : ListView.builder(
                itemCount: _cartProducts.length,
                itemBuilder: (context, index) {
                  final prod = _cartProducts[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${prod['productId']}')),
                    title: Text('Product ID: ${prod['productId']}'),
                    subtitle: Text(
                      'Quantity: ${prod['quantity']}\nCart ID: ${prod['cartId']} | User ID: ${prod['userId']}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
    );
  }
}
