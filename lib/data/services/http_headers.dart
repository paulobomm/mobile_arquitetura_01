import 'dart:io';

class DummyJsonHeaders {
  DummyJsonHeaders._();

  static void applyBase(HttpHeaders headers) {
    headers.contentType = ContentType.json;
  }

  static void applyWithToken(HttpHeaders headers, String token) {
    headers.contentType = ContentType.json;
    headers.set('Authorization', 'Bearer $token');
  }
}
