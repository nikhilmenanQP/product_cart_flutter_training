import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SignUpUseCase {
  final UserRepository repository;
  SignUpUseCase(this.repository);

  Future<void> call(User user) async {
    // Add any business logic or validation here if needed
    await repository.signUp(user);
  }
}
