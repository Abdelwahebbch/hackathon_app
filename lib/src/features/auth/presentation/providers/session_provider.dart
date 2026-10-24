import 'dart:async';
import 'package:hackathon_app/src/imports/imports.dart';
import 'package:hackathon_app/src/features/auth/domain/entities/user.dart';
import 'package:hackathon_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:hackathon_app/src/features/auth/data/repositories/auth_repository_impl.dart';

/// Exhaustive session variants — prefer `switch (state)` over status enums.
sealed class SessionState {
  const SessionState();

  AppUser? get userOrNull => switch (this) {
        SessionAuthenticated(:final user) => user,
        _ => null,
      };

  bool get isUnknown => this is SessionUnknown;
  bool get isAuthenticated => this is SessionAuthenticated;
  bool get isUnauthenticated => this is SessionUnauthenticated;
}

final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.user);
  final AppUser user;
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

SessionState sessionFromUser(AppUser? user) => switch (user) {
      final AppUser u => SessionAuthenticated(u),
      null => const SessionUnauthenticated(),
    };

/// Provides the AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provides a stream of auth state changes
final authStateStreamProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChanged;
});

/// Provides the current session state
final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return SessionNotifier(repository: repo);
});

class SessionNotifier extends StateNotifier<SessionState>
    with StreamSubscriptionsMixin {
  SessionNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const SessionUnknown()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    final result = await _repository.checkAuthState();
    state = result.fold(
      (_) => const SessionUnauthenticated(),
      sessionFromUser,
    );

    addSubscription(
      _repository.onAuthStateChanged.listen((user) {
        state = sessionFromUser(user);
      }),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const SessionUnauthenticated();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }
}
