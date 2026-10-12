abstract final class Validators {
  static bool email(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  static bool password(String value) => value.isNotEmpty;
  static bool registrationPassword(String value) => value.length >= 8;
}
