import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon_app/src/features/calculator/calculator_button.dart';
import 'package:hackathon_app/src/features/calculator/calculator_provider.dart';

// Local layout constants. Swap for AppSpacing.* if you prefer the shared tokens.
const double _gap = 12;
const double _pagePadding = 16;

/// A fully working calculator. It is the app's front door.
///
/// When the user types `+CODE=` (see [secretCodeProvider]) [onSecretCode] is
/// called. The calculator wipes its own display first, so nothing on screen
/// hints that anything happened.
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({this.onSecretCode, super.key});

  /// Called once each time the secret code is entered. Wire this to the
  /// router, e.g. `context.go(AppRoutes.emergency)`.
  final VoidCallback? onSecretCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(calculatorProvider.select((s) => s.unlockSignal), (
      previous,
      next,
    ) {
      if (next > (previous ?? 0)) onSecretCode?.call();
    });

    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      body: SafeArea(
        // Calculators are always left-to-right, even in Arabic.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              children: [
                const Expanded(flex: 2, child: _Display()),
                const SizedBox(height: _gap),
                Expanded(
                  flex: 5,
                  child: _Keypad(notifier: notifier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Display extends ConsumerWidget {
  const _Display();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            state.secondaryLine,
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            state.display,
            maxLines: 1,
            style: theme.textTheme.displayLarge?.copyWith(
              color: state.hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.notifier});

  final CalculatorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    CalculatorButton digit(String d) =>
        CalculatorButton(label: d, onPressed: () => notifier.inputDigit(d));

    CalculatorButton op(String symbol, String name) => CalculatorButton(
          label: symbol,
          semanticLabel: name,
          kind: CalculatorButtonKind.operator,
          onPressed: () => notifier.inputOperator(symbol),
        );

    final rows = <List<Widget>>[
      [
        CalculatorButton(
          label: 'AC',
          semanticLabel: 'All clear',
          kind: CalculatorButtonKind.function,
          onPressed: notifier.clear,
        ),
        CalculatorButton(
          label: '⌫',
          semanticLabel: 'Backspace',
          kind: CalculatorButtonKind.function,
          onPressed: notifier.backspace,
        ),
        CalculatorButton(
          label: '%',
          semanticLabel: 'Percent',
          kind: CalculatorButtonKind.function,
          onPressed: notifier.inputPercent,
        ),
        op('÷', 'Divide'),
      ],
      [digit('7'), digit('8'), digit('9'), op('×', 'Multiply')],
      [digit('4'), digit('5'), digit('6'), op('−', 'Subtract')],
      [digit('1'), digit('2'), digit('3'), op('+', 'Add')],
      [
        CalculatorButton(
          label: '±',
          semanticLabel: 'Toggle sign',
          onPressed: notifier.toggleSign,
        ),
        digit('0'),
        CalculatorButton(
          label: '.',
          semanticLabel: 'Decimal point',
          onPressed: notifier.inputDot,
        ),
        CalculatorButton(
          label: '=',
          semanticLabel: 'Equals',
          kind: CalculatorButtonKind.equals,
          onPressed: notifier.equals,
        ),
      ],
    ];

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(child: rows[r][c]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
