///AuthResult class,used to represent the result of an authentication operation.
class AuthResult {
  /// A constructor for the AuthResult class.
  AuthResult({required this.status, required this.message});

  /// success
  final bool status;

  /// message
  final String message;
}
