import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<void> signUp(User user) async {
    // Simulate a network/database call
    await Future.delayed(const Duration(seconds: 1));
    // You can add actual implementation here
  }
}
