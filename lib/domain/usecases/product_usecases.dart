import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);
  Future<List<Product>> call() => repository.getProducts();
}

class AddProductUseCase {
  final ProductRepository repository;
  AddProductUseCase(this.repository);
  Future<void> call(Product product) => repository.addProduct(product);
}

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);
  Future<void> call(int id) => repository.deleteProduct(id);
}

class EditProductUseCase {
  final ProductRepository repository;
  EditProductUseCase(this.repository);
  Future<void> call(Product product) => repository.editProduct(product);
}
