import "package:string_validator/string_validator.dart" as validator;

/// A utility class for string validation
class APZValidator {
  APZValidator._();

  /// Checks if the string contains only letters (a-zA-Z)
  static bool isAlpha(final String str) => validator.isAlpha(str);

  /// Checks if the string contains only letters and numbers
  static bool isAlphanumeric(final String str) => validator.isAlphanumeric(str);

  /// Checks if the string contains ASCII chars only
  static bool isAscii(final String str) => validator.isAscii(str);

  /// Checks if a string is base64 encoded
  static bool isBase64(final String str) => validator.isBase64(str);

  /// Checks if the string represents true/false
  // static bool isBool(String str) => validator.isBoolean(str);

  /// Checks if the string is a credit card number
  static bool isCreditCard(final String str) => validator.isCreditCard(str);

  /// Checks if the string is a valid date
  static bool isDate(final String str) => validator.isDate(str);

  /// Checks if the string represents a decimal number
  static bool isFloat(final String str) => validator.isFloat(str);

  /// Checks if the string is a valid email address
  static bool isEmail(final String str) => validator.isEmail(str);

  /// Checks if the string is a valid FQDN (Fully Qualified Domain Name)
  static bool isFQDN(final String str) => validator.isFQDN(str);

  /// Checks if the string contains only numbers
  static bool isNumeric(final String str) => validator.isNumeric(str);

  /// Checks if the string is a valid hex color
  static bool isHexColor(final String str) => validator.isHexColor(str);

  /// Checks if the string is a valid hex number
  static bool isHexadecimal(final String str) => validator.isHexadecimal(str);

  /// Checks if the string is a valid IP address (version 4 or 6)
  static bool isIP(final String str, [final String? version]) =>
      validator.isIP(str, version);

  /// Checks if the string is a valid IPv4 address
  static bool isIPv4(final String str) => validator.isIP(str, "4");

  /// Checks if the string is a valid IPv6 address
  static bool isIPv6(final String str) => validator.isIP(str, "6");

  /// Checks if the string is valid JSON
  static bool isJson(final String str) => validator.isJson(str);

  /// Checks if the string's length is between min and max
  static bool isLength(final String str, {final int min = 0, final int? max}) =>
      max != null ? str.length >= min && str.length <= max : str.length >= min;

  /// Checks if the string is lowercase
  static bool isLowercase(final String str) => validator.isLowercase(str);

  /// Checks if the string is uppercase
  static bool isUppercase(final String str) => validator.isUppercase(str);

  /// Checks if the string is a valid MAC address
  // static bool isMacAddress(String str) => validator.isMacAddress(str);

  /// Checks if the string is a valid MD5 hash
  // static bool isMd5(String str) => validator.isMD5(str);

  /// Checks if the string matches the pattern
  static bool matches(final String str, final String pattern) =>
      validator.matches(str, pattern);

  /// Checks if the string contains only numbers and is within a range
  static bool isNumberInRange(
    final String number, {
    final num? min,
    final num? max,
  }) {
    if (!isNumeric(number)) {
      return false;
    }
    final num value = num.parse(number);
    if (min != null && value < min) {
      return false;
    }
    if (max != null && value > max) {
      return false;
    }
    return true;
  }

  /// Checks if the string is a valid mobile phone number
  static bool isPhoneNumber(final String str) {
    // Basic phone number validation - can be customized based on your needs
    final RegExp phoneRegex = RegExp(r"^\+?[\d\s-]{10,}$");
    return phoneRegex.hasMatch(str.trim());
  }

  /// Checks if the string is a valid URL
  static bool isURL(final String str) => validator.isURL(str);

  /// Checks if the string contains only whitespace
  static bool isWhitespace(final String str) => str.trim().isEmpty;

  /// Checks if the string is empty or contains only whitespace
  static bool isEmpty(final String? str) => str == null || str.trim().isEmpty;

  /// Checks if the string is a valid password based on common requirements
  /// - At least 8 characters long
  /// - Contains at least one uppercase letter
  /// - Contains at least one lowercase letter
  /// - Contains at least one number
  /// - Contains at least one special character
  static bool isStrongPassword(final String str) {
    if (str.length < 8) {
      return false;
    }

    final bool hasUppercase = RegExp("[A-Z]").hasMatch(str);
    final bool hasLowercase = RegExp("[a-z]").hasMatch(str);
    final bool hasNumbers = RegExp("[0-9]").hasMatch(str);
    final bool hasSpecialCharacters = RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasMatch(str);

    return hasUppercase && hasLowercase && hasNumbers && hasSpecialCharacters;
  }

  /// Checks if the string contains another string
  static bool contains(final String str, final String seed) =>
      str.contains(seed);

  /// Checks if the string equals another string
  static bool equals(final String str, final String comparison) =>
      str == comparison;

  /// Checks if the string matches a regular expression pattern
  static bool matchesPattern(final String str, final Pattern pattern) =>
      RegExp(pattern.toString()).hasMatch(str);
}
