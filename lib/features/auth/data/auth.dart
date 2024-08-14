import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

enum AuthState {
  initial,
  success,
  error,
}

class AuthData {
  AuthData({required this.state, this.message = '', this.token = ''});

  AuthState state;
  String message;
  String token;
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthData> build() async {
    return AuthData(state: AuthState.initial);
  }

  Future<void> register(String server, username, password) async {
    final response = await http.post(
      Uri.http(server.replaceFirst('http://', '').replaceFirst('9001/', '9001'), 'auth/register'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'username': username,
        'password': password,
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    state = AsyncData(AuthData(state: AuthState.success, token: json['data']));
  }

  Future<void> login(String server, username, password) async {
    final response = await http.post(
      Uri.http(server.replaceFirst('http://', '').replaceFirst('9001/', '9001'), 'auth/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        'username': username,
        'password': password,
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    state = AsyncData(AuthData(state: AuthState.success, token: json['data']));
  }
}