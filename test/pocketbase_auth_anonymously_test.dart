import 'package:pocketbase_auth_anonymously/src/utils.dart';
import 'package:test/test.dart';

void main() {
  test('generateRandomId produces 15 lowercase alphanumeric chars', () {
    final id = defaultIdGenerator();
    expect(id.length, 15);
    expect(RegExp(r'^[a-z0-9]{15}$').hasMatch(id), isTrue);
  });

  test('generatePassword produces 32 alphanumeric chars', () {
    final p1 = defaultPasswordGenerator();
    final p2 = defaultPasswordGenerator();
    expect(p1.length, 32);
    expect(RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(p1), isTrue);
    // Very small chance of collision; ensure two generated passwords differ
    expect(p1 == p2, isFalse);
  });

  test('anonymousEmail formats id and domain', () {
    final email = anonymousEmail('abc123', 'example.com');
    expect(email, 'abc123@example.com');
  });
}
