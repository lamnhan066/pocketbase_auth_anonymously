import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

import 'utils.dart';

extension PocketbaseAnonymousAuthExtension on PocketBase {
  RecordService get _userCollection => collection('users');

  /// Authenticates anonymously. If an anonymous user already exists and has a
  /// valid token, it will be returned. Otherwise, a new anonymous user will be
  /// created and signed in.
  ///
  /// Use [idGenerator] and [passwordGenerator] to customize how the anonymous
  /// user's id and password are generated. By default, the id is a 15-character
  /// lowercase alphanumeric string, and the password is a 32-character alphanumeric
  /// string.
  ///
  /// You can customize the anonymous user creation by providing [body], which
  /// will be merged into the request body when creating a new anonymous user.
  ///
  /// The [domain] parameter is used to generate the email for the anonymous user,
  /// which has the format `<anonymousId>@<domain>`.
  ///
  /// The [maxRetries] parameter controls how many times the function will
  /// attempt to create a new anonymous user if there are collisions with
  /// the generated id.
  Future<RecordAuth?> authAnonymously({
    String Function() idGenerator = defaultIdGenerator,
    String Function() passwordGenerator = defaultPasswordGenerator,
    String? expand,
    String? fields,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
    String domain = 'anonymous.local',
    int maxRetries = 3,
  }) async {
    try {
      final recordAuth = await _userCollection.authRefresh(
        expand: expand,
        fields: fields,
        body: body,
        query: query,
        headers: headers,
      );

      if (authStore.isValid) return recordAuth;
    } on ClientException catch (e) {
      if (e.statusCode != 401) rethrow;

      authStore.clear();
    }

    var id = idGenerator();
    final password = passwordGenerator();

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final email = anonymousEmail(id, domain);

      try {
        final enrichedBody = Map<String, dynamic>.of(body);
        enrichedBody["id"] = id;
        enrichedBody["email"] = email;
        enrichedBody["password"] = password;
        enrichedBody["passwordConfirm"] = password;

        await _userCollection.create(
          body: enrichedBody,
          expand: expand,
          fields: fields,
          query: query,
          headers: headers,
        );
      } on ClientException catch (e) {
        if (e.statusCode != 400) rethrow;

        id = idGenerator();
        continue;
      }

      final recordAuth = await _userCollection.authWithPassword(
        email,
        password,
        expand: expand,
        fields: fields,
        body: body,
        query: query,
        headers: headers,
      );
      return recordAuth;
    }
    return null;
  }
}
