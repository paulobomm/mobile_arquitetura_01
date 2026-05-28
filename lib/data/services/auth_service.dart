import 'dart:convert';
import 'dart:io';
import 'package:product_app/data/models/user_model.dart';
import 'package:product_app/data/services/http_headers.dart';

class AuthService {
  static const _baseUrl = 'https://dummyjson.com';

  Future<UserModel> login(String username, String password) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl/auth/login'));
      DummyJsonHeaders.applyBase(request.headers);
      request.write(jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return UserModel.fromJson(data);
      }
      final message = data['message']?.toString() ?? 'Credenciais inválidas';
      throw Exception(message);
    } finally {
      client.close();
    }
  }

  Future<UserModel> getMe(String token) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('$_baseUrl/auth/me'));
      DummyJsonHeaders.applyWithToken(request.headers, token);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        return UserModel.fromJson({...data, 'token': token});
      }
      throw Exception('Sessão expirada');
    } finally {
      client.close();
    }
  }
}
