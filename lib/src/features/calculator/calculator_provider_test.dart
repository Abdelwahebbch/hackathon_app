import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon_app/src/features/calculator/calculator_provider.dart';

void main() {
  late ProviderContainer container;
  late CalculatorNotifier calc;

  CalculatorState state() => container.read(calculatorProvider);

  void type(String keys) {
    for (final k in keys.split('')) {
      switch (k) {
        case '+' || '−' || '×' || '÷':
          calc.inputOperator(k);
        case '.':
          calc.inputDot();
        case '%':
          calc.inputPercent();
        case '=':
          calc.equals();
        default:
          calc.inputDigit(k);
      }
    }
  }

  setUp(() {
    container = ProviderContainer(
      overrides: [secretCodeProvider.overrideWithValue('4821')],
    );
    calc = container.read(calculatorProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('computes with precedence', () {
    type('2+3×4=');
    expect(state().display, '14');
    expect(state().history, '2+3×4');
  });

  test('live preview while typing', () {
    type('2+3');
    expect(state().preview, '5');
  });

  test('no leading zeros and single decimal point', () {
    type('007');
    expect(state().display, '7');
    type('.5.5');
    expect(state().display, '7.55');
  });

  test('operator replaces previous operator', () {
    type('5+×3=');
    expect(state().display, '15');
  });

  test('typing after result starts fresh; operator continues', () {
    type('2+2=');
    type('9');
    expect(state().display, '9');
    calc.clear();
    type('2+2=');
    type('×3=');
    expect(state().display, '12');
  });

  test('division by zero shows Error and recovers', () {
    type('5÷0=');
    expect(state().display, 'Error');
    type('3');
    expect(state().display, '3');
  });

  test('backspace and clear', () {
    type('123');
    calc.backspace();
    expect(state().display, '12');
    calc.clear();
    expect(state().display, '0');
  });

  test('toggle sign', () {
    type('5');
    calc.toggleSign();
    expect(state().display, '−5');
    calc.toggleSign();
    expect(state().display, '5');
    type('−3');
    calc.toggleSign();
    expect(state().display, '5+3');
  });

  group('secret code', () {
    test('+CODE= fires the signal and wipes the display', () {
      type('+4821=');
      expect(state().unlockSignal, 1);
      expect(state().display, '0');
      expect(state().preview, '');
    });

    test('fires again on a second entry', () {
      type('+4821=');
      type('+4821=');
      expect(state().unlockSignal, 2);
    });

    test('wrong code or missing plus behaves like a normal calculator', () {
      type('+1111=');
      expect(state().unlockSignal, 0);
      expect(state().display, '1111');

      calc.clear();
      type('4821=');
      expect(state().unlockSignal, 0);
      expect(state().display, '4821');
    });

    test('no preview leaks the code while typing', () {
      type('+4821');
      expect(state().preview, '');
    });
  });
}
