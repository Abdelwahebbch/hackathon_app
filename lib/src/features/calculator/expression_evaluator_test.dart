import 'package:flutter_test/flutter_test.dart';

import 'package:hackathon_app/src/features/calculator/expression_evaluator.dart';
import 'package:hackathon_app/src/features/calculator/secret_code_matcher.dart';

void main() {
  const evaluator = ExpressionEvaluator();

  group('ExpressionEvaluator', () {
    test('basic arithmetic and precedence', () {
      expect(evaluator.evaluate('2+3×4'), 14);
      expect(evaluator.evaluate('10−4÷2'), 8);
      expect(evaluator.evaluate('8÷4×3'), 6);
    });

    test('decimals', () {
      expect(ExpressionEvaluator.format(evaluator.evaluate('0.1+0.2')), '0.3');
    });

    test('unary signs', () {
      expect(evaluator.evaluate('+5'), 5);
      expect(evaluator.evaluate('−5+2'), -3);
      expect(evaluator.evaluate('5×−3'), -15);
      expect(evaluator.evaluate('5−−3'), 8);
    });

    test('percent', () {
      expect(evaluator.evaluate('50%'), 0.5);
      expect(evaluator.evaluate('200×10%'), 20);
    });

    test('errors', () {
      expect(
          () => evaluator.evaluate('5÷0'), throwsA(isA<ExpressionException>()));
      expect(
          () => evaluator.evaluate('5+'), throwsA(isA<ExpressionException>()));
      expect(() => evaluator.evaluate(''), throwsA(isA<ExpressionException>()));
    });

    test('format', () {
      expect(ExpressionEvaluator.format(14), '14');
      expect(ExpressionEvaluator.format(-3), '−3');
      expect(ExpressionEvaluator.format(-0.0), '0');
    });
  });

  group('SecretCodeMatcher', () {
    const matcher = SecretCodeMatcher('1234');

    test('matches only +CODE', () {
      expect(matcher.matches('+1234'), isTrue);
      expect(matcher.matches('1234'), isFalse);
      expect(matcher.matches('+12345'), isFalse);
      expect(matcher.matches('+1234+1'), isFalse);
    });
  });
}
