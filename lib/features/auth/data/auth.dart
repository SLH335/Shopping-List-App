import 'dart:convert';

import 'package:shoppinglist/features/auth/domain/user.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

enum AuthState {
  initial,
  success,
  error,
}

class AuthData {
  AuthData({required this.state, this.user, this.message = '', this.token = '', this.server = ''});

  AuthState state;
  String message;
  User? user;
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
    if (!server.startsWith('http://') && !server.startsWith('https://')) {
      server = 'https://$server';
    }
    Response response;
    try {
      response = await post(
        Uri.parse('$server/auth/register'),
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
      state = AsyncData(AuthData(state: AuthState.error, message: 'Fehler: Ungültige Antwort'));
      return;
    }
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    if (json['data'] == null || json['data']['token'] == null || json['data']['user'] == null) {
      state = AsyncData(AuthData(
        state: AuthState.error,
        message: 'Fehler: Die Sitzung konnte nicht aufgebaut werden',
      ));
      return;
    }

    final user = User.fromJson(json['data']['user']);
    state = AsyncData(AuthData(
      state: AuthState.success,
      user: user,
      token: json['data']['token'],
      server: server,
    ));
  }

  Future<void> login(String server, String username, String password) async {
    if (!server.startsWith('http://') && !server.startsWith('https://')) {
      server = 'https://$server';
    }
    Response response;
    try {
      response = await post(
        Uri.parse('$server/auth/login'),
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
      state = AsyncData(AuthData(
        state: AuthState.error,
        message: 'Fehler: Server ist nicht erreichbar',
      ));
      return;
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (ex) {
      state = AsyncData(AuthData(state: AuthState.error, message: 'Fehler: Ungültige Antwort'));
      return;
    }
    if (response.statusCode != 200 || !json['success']) {
      state = AsyncData(AuthData(state: AuthState.error, message: json['message']));
      return;
    }

    if (json['data'] == null || json['data']['token'] == null || json['data']['user'] == null) {
      state = AsyncData(AuthData(
        state: AuthState.error,
        message: 'Fehler: Die Sitzung konnte nicht aufgebaut werden',
      ));
      return;
    }

    final user = User.fromJson(json['data']['user']);
    state = AsyncData(AuthData(
      state: AuthState.success,
      user: user,
      token: json['data']['token'],
      server: server,
    ));
  }
}
