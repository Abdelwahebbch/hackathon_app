import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon_app/src/features/calculator/expression_evaluator.dart';
import 'package:hackathon_app/src/features/calculator/secret_code_matcher.dart';

/// The digits that, typed as `+CODE=`, reveal the hidden app.
///
/// Placeholder: override this provider with the code the user chose
/// (e.g. loaded from `flutter_secure_storage`) in the root `ProviderScope`.
final secretCodeProvider = Provider<String>((ref) => '1234');

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
  CalculatorNotifier.new,
);

class CalculatorState {
  const CalculatorState({
    this.expression = '',
    this.preview = '',
    this.history = '',
    this.justEvaluated = false,
    this.hasError = false,
    this.unlockSignal = 0,
  });

  /// What the user has typed (or the last result right after `=`).
  final String expression;

  /// Live result shown in small text while typing a calculation.
  final String preview;

  /// The expression that produced the current result, shown after `=`.
  final String history;

  final bool justEvaluated;
  final bool hasError;

  /// Incremented each time the secret code is entered. The screen listens to
  /// this value; it never appears on screen.
  final int unlockSignal;

  String get display {
    if (hasError) return 'Error';
    return expression.isEmpty ? '0' : expression;
  }

  /// Text for the small line above the main display.
  String get secondaryLine => justEvaluated ? history : preview;
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  static const _evaluator = ExpressionEvaluator();
  static const _operators = {'+', '−', '×', '÷'};
  static final _lastNumber = RegExp(r'(\d+\.?\d*|\.\d+)$');
  static final _plainNumber = RegExp(r'^[+−]?\d+\.?\d*$');
  static const _maxNumberLength = 15;

  @override
  CalculatorState build() => const CalculatorState();

  // ---------------------------------------------------------------- input --

  void inputDigit(String digit) {
    var expr = _editable;
    if (expr.endsWith('%')) expr += '×';

    final match = _lastNumber.firstMatch(expr);
    if (match != null) {
      final number = match.group(0)!;
      if (number == '0') {
        expr = expr.substring(0, match.start) + digit;
        return _set(expr);
      }
      if (number.length >= _maxNumberLength) return;
    }
    _set(expr + digit);
  }

  void inputDot() {
    var expr = _editable;
    if (expr.endsWith('%')) expr += '×';

    final match = _lastNumber.firstMatch(expr);
    if (match == null) return _set('${expr}0.');
    if (match.group(0)!.contains('.')) return;
    _set('$expr.');
  }

  void inputOperator(String op) {
    var expr = state.hasError ? '' : state.expression;
    expr = expr.endsWith('.') ? expr.substring(0, expr.length - 1) : expr;

    if (expr.isEmpty) {
      return _set(op == '+' || op == '−' ? op : '0$op');
    }

    final last = expr[expr.length - 1];
    if (_operators.contains(last)) {
      // A lone sign can only become another sign; otherwise swap operators.
      if (expr.length == 1 && op != '+' && op != '−') return;
      return _set(expr.substring(0, expr.length - 1) + op);
    }
    _set(expr + op);
  }

  void inputPercent() {
    var expr = state.hasError ? '' : state.expression;
    if (expr.endsWith('.')) expr = expr.substring(0, expr.length - 1);
    if (expr.isEmpty) return;
    final last = expr[expr.length - 1];
    final isDigit = last.codeUnitAt(0) >= 48 && last.codeUnitAt(0) <= 57;
    if (!isDigit && last != '%') return;
    _set('$expr%', keepEvaluated: state.justEvaluated);
  }

  void toggleSign() {
    final expr = state.hasError ? '' : state.expression;
    final match = RegExp(r'(\d+\.?\d*|\.\d+)%*$').firstMatch(expr);
    if (match == null) return;

    var before = expr.substring(0, match.start);
    final number = expr.substring(match.start);
    final prevIsSign = before.endsWith('−') || before.endsWith('+');
    if (prevIsSign) {
      final head = before.substring(0, before.length - 1);
      final isUnaryMinus = before.endsWith('−') &&
          (head.isEmpty || _operators.contains(head[head.length - 1]));
      if (isUnaryMinus) {
        before = head; // −5 → 5
      } else if (before.endsWith('−')) {
        before = '$head+'; // 8−5 → 8+5
      } else {
        before = '$head−'; // 8+5 → 8−5, +5 → −5
      }
    } else {
      before = '$before−';
    }
    _set(before + number, keepEvaluated: state.justEvaluated);
  }

  void backspace() {
    if (state.justEvaluated || state.hasError) return clear();
    final expr = state.expression;
    if (expr.isEmpty) return;
    _set(expr.substring(0, expr.length - 1));
  }

  void clear() {
    state = CalculatorState(unlockSignal: state.unlockSignal);
  }

  void equals() {
    if (state.hasError || state.justEvaluated) return;
    final expr = state.expression;

    // Hidden behaviour: `+CODE=` signals the screen to switch apps. The
    // display is wiped so nothing remains on the calculator afterwards.
    final matcher = SecretCodeMatcher(ref.read(secretCodeProvider));
    print(matcher.matches(expr));
    if (matcher.matches(expr)) {
      state = CalculatorState(unlockSignal: state.unlockSignal + 1);
      return;
    }

    final cleaned = _trimTrailing(expr);
    if (cleaned.isEmpty) return;

    try {
      final result = ExpressionEvaluator.format(_evaluator.evaluate(cleaned));
      state = CalculatorState(
        expression: result,
        history: cleaned,
        justEvaluated: true,
        unlockSignal: state.unlockSignal,
      );
    } on ExpressionException {
      state = CalculatorState(
        hasError: true,
        justEvaluated: true,
        unlockSignal: state.unlockSignal,
      );
    }
  }

  // -------------------------------------------------------------- helpers --

  /// The text to append to: empty after a result or an error.
  String get _editable =>
      (state.justEvaluated || state.hasError) ? '' : state.expression;

  String _trimTrailing(String expr) =>
      expr.replaceAll(RegExp(r'[+−×÷.]+$'), '');

  void _set(String expr, {bool keepEvaluated = false}) {
    state = CalculatorState(
      expression: expr,
      preview: _previewFor(expr),
      history: keepEvaluated ? state.history : '',
      justEvaluated: keepEvaluated,
      unlockSignal: state.unlockSignal,
    );
  }

  /// Live result for the small line. Empty for plain numbers (including a
  /// leading-sign number like `+1234`) so nothing unusual is displayed.
  String _previewFor(String expr) {
    final cleaned = _trimTrailing(expr);
    if (cleaned.isEmpty || _plainNumber.hasMatch(cleaned)) return '';
    try {
      return ExpressionEvaluator.format(_evaluator.evaluate(cleaned));
    } on ExpressionException {
      return '';
    }
  }
}
