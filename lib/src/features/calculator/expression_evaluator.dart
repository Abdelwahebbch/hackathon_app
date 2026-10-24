/// Thrown when an expression cannot be evaluated (syntax error, divide by zero).
class ExpressionException implements Exception {
  const ExpressionException(this.message);

  final String message;

  @override
  String toString() => 'ExpressionException: $message';
}

/// Evaluates calculator expressions such as `12+3×4−5%`.
///
/// Supported: `+ − × ÷` (also `- * /`), decimals, unary `+`/`−`, and a
/// postfix `%` (divides the number by 100).
///
/// Grammar:
/// ```text
/// expression := term (('+' | '−') term)*
/// term       := unary (('×' | '÷') unary)*
/// unary      := ('+' | '−') unary | postfix
/// postfix    := number '%'*
/// ```
class ExpressionEvaluator {
  const ExpressionEvaluator();

  double evaluate(String input) {
    final value = _Parser(input).parse();
    if (value.isNaN || value.isInfinite) {
      throw const ExpressionException('Result is not a finite number');
    }
    return value;
  }

  /// Formats [value] for display: at most 12 significant digits, no trailing
  /// zeros, no `-0`.
  static String format(double value) {
    final rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded == 0) return '0';
    if (rounded == rounded.truncateToDouble() && rounded.abs() < 1e15) {
      return rounded.toInt().toString().replaceAll('-', '−');
    }
    return rounded.toString().replaceAll('-', '−');
  }
}

class _Parser {
  _Parser(String source) : _src = _normalize(source);

  final String _src;
  int _pos = 0;

  static String _normalize(String s) => s
      .replaceAll('-', '−')
      .replaceAll('*', '×')
      .replaceAll('/', '÷')
      .replaceAll(' ', '');

  double parse() {
    if (_src.isEmpty) throw const ExpressionException('Empty expression');
    final value = _expression();
    if (_pos != _src.length) {
      throw ExpressionException('Unexpected "${_src[_pos]}" at $_pos');
    }
    return value;
  }

  bool _match(String ch) {
    if (_pos < _src.length && _src[_pos] == ch) {
      _pos++;
      return true;
    }
    return false;
  }

  double _expression() {
    var value = _term();
    while (true) {
      if (_match('+')) {
        value += _term();
      } else if (_match('−')) {
        value -= _term();
      } else {
        return value;
      }
    }
  }

  double _term() {
    var value = _unary();
    while (true) {
      if (_match('×')) {
        value *= _unary();
      } else if (_match('÷')) {
        final divisor = _unary();
        if (divisor == 0) {
          throw const ExpressionException('Division by zero');
        }
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _unary() {
    if (_match('+')) return _unary();
    if (_match('−')) return -_unary();
    return _postfix();
  }

  double _postfix() {
    var value = _number();
    while (_match('%')) {
      value /= 100;
    }
    return value;
  }

  double _number() {
    final start = _pos;
    var seenDot = false;
    while (_pos < _src.length) {
      final c = _src[_pos];
      final isDigit = c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
      if (isDigit) {
        _pos++;
      } else if (c == '.' && !seenDot) {
        seenDot = true;
        _pos++;
      } else {
        break;
      }
    }
    final text = _src.substring(start, _pos);
    if (text.isEmpty || text == '.') {
      throw ExpressionException('Number expected at $start');
    }
    return double.parse(text);
  }
}
