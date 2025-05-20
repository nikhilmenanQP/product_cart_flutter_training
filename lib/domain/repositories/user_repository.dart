import '../entities/user.dart';

abstract class UserRepository {
  Future<void> signUp(User user);
}
