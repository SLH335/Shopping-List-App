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
  AuthData({required this.state, this.message = '', this.token = '', this.server = ''});

  AuthState state;
  String message;
  String token;
  String server;
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthData> build() async {
    return AuthData(state: AuthState.initial);
  }

  Future<void> register(String server, String username, String password) async {
    http.Response response;
    server = server.replaceFirst('http://', '').replaceFirst('9001/', '9001');
    try {
      response = await http.post(
        Uri.http(server, 'auth/register'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          'username': username,
          'password': password,
        },
      );
    } catch (ex) {
      state = AsyncData(
          AuthData(state: AuthState.error, message: 'Fehler: Server ist nicht erreichbar'));
      return;
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (ex) {
      state = AsyncData(
          AuthData(state: AuthState.error, message: 'Fehler: Ungültige Antwort'));
      return;
    }
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    if (json['data'] == null) {
      state = AsyncData(AuthData(state: AuthState.error, message: 'Fehler: Die Sitzung konnte nicht aufgebaut werden'));
      return;
    }
    state = AsyncData(AuthData(state: AuthState.success, token: json['data'], server: server));
  }

  Future<void> login(String server, String username, String password) async {
    server = server.replaceFirst('http://', '').replaceFirst('9001/', '9001');
    http.Response response;
    try {
      response = await http.post(
        Uri.http(server, 'auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          'username': username,
          'password': password,
        },
      );
    } catch (ex) {
      state = AsyncData(
          AuthData(state: AuthState.error, message: 'Fehler: Server ist nicht erreichbar'));
      return;
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (ex) {
      state = AsyncData(
          AuthData(state: AuthState.error, message: 'Fehler: Ungültige Antwort'));
      return;
    }
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    if (json['data'] == null) {
      state = AsyncData(AuthData(state: AuthState.error, message: 'Fehler: Die Sitzung konnte nicht aufgebaut werden'));
      return;
    }
    state = AsyncData(AuthData(state: AuthState.success, token: json['data'], server: server));
  }
}
