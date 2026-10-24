/// Detects the hidden unlock sequence typed on the calculator.
///
/// The sequence is `+` followed by the secret code and then `=`. This matcher
/// receives the expression typed so far at the moment `=` is pressed, so it
/// only needs to check for `+CODE`.
///
/// A leading `+` is valid calculator input (`+5=` is just 5), so ordinary use
/// is unaffected and the camouflage holds.
class SecretCodeMatcher {
  const SecretCodeMatcher(this.code)
      : assert(code.length > 0, 'Secret code must not be empty');

  /// Digits only (the calculator keypad has no letters), e.g. `1234`.
  final String code;

  bool matches(String expression) => expression == '+$code';
}
