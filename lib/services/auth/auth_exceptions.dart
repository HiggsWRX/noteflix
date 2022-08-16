// LOGIN exceptions
class UserNotFoundAuthException implements Exception {}

class WrongCredentialsAuthException implements Exception {}

// REGISTER exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// GENERIC exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
