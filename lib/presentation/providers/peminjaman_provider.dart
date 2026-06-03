import 'package:flutter/material.dart';
import '../../core/utils/view_state.dart';
import '../../domain/entities/peminjaman.dart';
import '../../domain/repositories/peminjaman_repository.dart';

class PeminjamanProvider extends ChangeNotifier {
  final PeminjamanRepository _peminjamanRepository;

  PeminjamanProvider(this._peminjamanRepository);

  List<Peminjaman> _loans = [];
  List<Peminjaman> get loans => _loans;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchLoans() async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      _loans = await _peminjamanRepository.getAllPeminjaman();
      _setState(ViewState.loaded);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
    }
  }

  Future<bool> createLoan({
    required String namaAnggota,
    required String nim,
    required String bukuId,
    required DateTime tanggalKembali,
  }) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      final newLoan = await _peminjamanRepository.createPeminjaman(
        namaAnggota: namaAnggota,
        nim: nim,
        bukuId: bukuId,
        tanggalKembali: tanggalKembali,
      );
      _loans.insert(0, newLoan); // Masukkan ke posisi teratas
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }

  Future<bool> returnBook(String id) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      final updatedLoan = await _peminjamanRepository.kembalikanBuku(id);
      final index = _loans.indexWhere((element) => element.id == id);
      if (index != -1) {
        _loans[index] = updatedLoan;
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
