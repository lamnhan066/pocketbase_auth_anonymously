import 'dart:math';

/// Generates a cryptographically secure 15-character id using
/// [a-z0-9]. Separated out for testing.
String defaultIdGenerator() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < 15; i++) {
    buffer.writeCharCode(chars.codeUnitAt(rand.nextInt(chars.length)));
  }
  return buffer.toString();
}

/// Generates a cryptographically secure 32-character password using
/// [a-zA-Z0-9]. Separated out for testing.
String defaultPasswordGenerator() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < 32; i++) {
    buffer.writeCharCode(chars.codeUnitAt(rand.nextInt(chars.length)));
  }
  return buffer.toString();
}

/// Builds the anonymous email string `<id>@<domain>`.
String anonymousEmail(String anonymousId, String domain) =>
    '$anonymousId@$domain';
