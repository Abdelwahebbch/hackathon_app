import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CalculatorButtonKind { digit, function, operator, equals }

/// One key of the calculator keypad. Colors come from the active theme so the
/// keypad follows light/dark mode and the app's Material 3 color scheme.
class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    required this.label,
    required this.onPressed,
    this.kind = CalculatorButtonKind.digit,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final CalculatorButtonKind kind;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (kind) {
      CalculatorButtonKind.digit => (
          scheme.surfaceContainerHigh,
          scheme.onSurface,
        ),
      CalculatorButtonKind.function => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      CalculatorButtonKind.operator => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      CalculatorButtonKind.equals => (scheme.primary, scheme.onPrimary),
    };

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
