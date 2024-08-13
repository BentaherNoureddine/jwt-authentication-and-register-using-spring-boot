


import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtHelper {
  static Map<String, dynamic>? decodeJwt(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload;
    } catch (e) {
        throw e.toString();
    }
  }
}