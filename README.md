# PocketBase Auth Anonymously

Lightweight extension for the `pocketbase` Dart client that creates and signs-in an anonymous user when no valid session exists.

## Features

- Creates an anonymous user record with a random id and password.
- Attempts to reuse an existing valid session when available.
- Configurable request parameters and email `domain` used to build the anonymous email (e.g. `<id>@anonymous.local`).

## Installation

Add the package to your `pubspec.yaml` dependencies:

```yaml
dependencies:
	pocketbase:
	pocketbase_auth_anonymously:
```

## Usage

To ensure the anonymous account works as expected, we have to cache the `AuthStore`.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_auth_anonymously/pocketbase_auth_anonymously.dart';

final _secureStorage = FlutterSecureStorage();
final _initial = await _secureStorage.read(key: 'auth_store');

final authStore = AsyncAuthStore(
    initial: _initial,
    save: (data) => _secureStorag.write(key: 'auth_store', value: data),
    clear: () => _secureStorag.delete(key: 'auth_store'),
);

final client = PocketBase('https://example.com', authStore: authStore);

// Signs in an anonymous user (creates it if necessary).
final auth = await client.authAnonymously();
if (auth != null) {
	print('Signed in as: ${auth.record.id}');
}
```

The `authAnonymously` extension returns a `Future<RecordAuth?>` from the `pocketbase` package. It will try to refresh an existing session and, if none exists, create a new anonymous user and sign in.

## Notes & Tips
- To reduce anonymous user churn, increase the `Auth duration` in the PocketBase admin UI: Dashboard → `users` Collection → Settings → Options → Other → Auth duration.
- The extension will retry id generation on 400 responses (id collision).

## Troubleshooting
- If creation fails with repeated 400 errors, confirm the `users` collection schema accepts the supplied fields and that no unique constraints block creation.
- Network or permission errors return `null` from `authAnonymously` - check the thrown exceptions in your app logs for details.

## Contributing
- Bug reports, tests, and small PRs are welcome.

## License
- Distributed under the terms of the MIT license. See `LICENSE` for details.

