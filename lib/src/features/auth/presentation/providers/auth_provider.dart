import 'package:hackathon_app/src/imports/core_imports.dart';
import 'package:hackathon_app/src/imports/packages_imports.dart';
import 'package:hackathon_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:hackathon_app/src/features/auth/data/repositories/auth_repository_impl.dart';

// Provides the single instance of AuthRepositoryImpl
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, RequestState<void>>((ref) {
  return AuthController(
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthController extends StateNotifier<RequestState<void>> {
  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(const RequestInitial());

  final AuthRepository _repository;

  void login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = const RequestLoading();

    final result = await _repository.login(email: email, password: password);

    result.fold(
      (failure) {
        state = RequestFailure(failure);
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (_) {
        state = const RequestSuccess(null);
        if (rootContext?.mounted ?? false) {
          rootContext!.go(AppRoutes.home);
        }
      },
    );
  }

  void signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    state = const RequestLoading();

    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = RequestFailure(failure);
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (_) {
        state = const RequestSuccess(null);
        if (rootContext?.mounted ?? false) {
          rootContext!.go(AppRoutes.home);
        }
      },
    );
  }

  void forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = const RequestLoading();

    final result = await _repository.forgotPassword(email: email);

    result.fold(
      (failure) {
        state = RequestFailure(failure);
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (_) {
        state = const RequestSuccess(null);
        if (context.mounted) {
          showToast(
            context,
            message: 'Password reset link sent successfully',
            status: 'success',
          );
        }
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
