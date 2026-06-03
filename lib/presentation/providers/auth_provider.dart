import 'package:flutter/material.dart';
import '../../core/utils/view_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      _user = await _authRepository.login(username, password);
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }

  Future<void> logout() async {
    _setState(ViewState.loading);
    await _authRepository.logout();
    _user = null;
    _setState(ViewState.initial);
  }

  Future<void> checkSession() async {
    _setState(ViewState.loading);
    try {
      _user = await _authRepository.getSession();
      _setState(ViewState.loaded);
    } catch (e) {
      _user = null;
      _setState(ViewState.initial);
    }
  }
}
