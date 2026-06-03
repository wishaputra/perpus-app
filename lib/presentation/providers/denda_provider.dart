import 'package:flutter/material.dart';
import '../../core/utils/view_state.dart';
import '../../domain/entities/denda.dart';
import '../../domain/repositories/denda_repository.dart';

class DendaProvider extends ChangeNotifier {
  final DendaRepository _dendaRepository;

  DendaProvider(this._dendaRepository);

  List<Denda> _fines = [];
  List<Denda> get fines => _fines;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchFines() async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      _fines = await _dendaRepository.getAllDenda();
      _setState(ViewState.loaded);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
    }
  }

  Future<bool> payFine(String id) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      final updatedFine = await _dendaRepository.bayarDenda(id);
      final index = _fines.indexWhere((element) => element.id == id);
      if (index != -1) {
        _fines[index] = updatedFine;
      }
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }
}
