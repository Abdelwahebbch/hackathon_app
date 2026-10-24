import 'package:hackathon_app/src/imports/core_imports.dart';
import 'package:hackathon_app/src/imports/packages_imports.dart';

import 'package:hackathon_app/src/features/auth/presentation/providers/session_provider.dart';

class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      AppLogger.provider(
        'Session state changed',
        context: {
          'state': switch (next) {
            SessionUnknown() => 'unknown',
            SessionAuthenticated() => 'authenticated',
            SessionUnauthenticated() => 'unauthenticated',
          },
        },
      );
      switch (next) {
        case SessionUnknown():
          break;
        case SessionAuthenticated():
          FlutterNativeSplash.remove();
          context.go(AppRoutes.home);
        case SessionUnauthenticated():
          FlutterNativeSplash.remove();
          context.go(AppRoutes.onboarding);
      }
    });

    return child;
  }
}
