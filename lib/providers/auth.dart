import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get auth {
    return getToken != null;
  }

  String get getUserId {
    return _userId;
  }

  String get getToken {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  void logout() async {
    debugPrint('ddd');
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    // pref.remove(key);
    pref.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(pref.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> _authentication(
      String email, String password, String path) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$path?key=AIzaSyBEsCjw05L0NXJJiFa29Om-mXn6plxu3-s');
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final pref = await SharedPreferences.getInstance();

      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      pref.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authentication(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authentication(email, password, 'signInWithPassword');
  }
}
