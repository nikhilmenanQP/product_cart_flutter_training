import 'dart:convert';
import '../../core/api_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient = ApiClient(baseUrl: 'https://fakestoreapi.com');

  @override
  Future<List<Product>> getProducts() async {
    final response = await _apiClient.get('/products');
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Product>(
          (item) => Product(
            id: item['id'] ?? 0,
            title: item['title'] ?? '',
            price:
                (item['price'] is int)
                    ? (item['price'] as int).toDouble()
                    : (item['price'] as num?)?.toDouble() ?? 0.0,
            description: item['description'] ?? '',
            category: item['category'] ?? '',
            image: item['image'] ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await _apiClient.post(
      '/products',
      body: {
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'image': product.image,
        'category': product.category,
      },
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _apiClient.delete('/products/$id');
  }

  @override
  Future<void> editProduct(Product product) async {
    await _apiClient.put(
      '/products/${product.id}',
      body: {
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'image': product.image,
        'category': product.category,
      },
    );
  }
}
