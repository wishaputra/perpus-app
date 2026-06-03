import 'package:flutter/material.dart';
import '../../core/utils/view_state.dart';
import '../../domain/entities/buku.dart';
import '../../domain/repositories/buku_repository.dart';

class BukuProvider extends ChangeNotifier {
  final BukuRepository _bukuRepository;

  BukuProvider(this._bukuRepository);

  List<Buku> _books = [];
  List<Buku> get books => _books;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      _books = await _bukuRepository.getAllBuku();
      _setState(ViewState.loaded);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
    }
  }

  Future<bool> addBook(Buku buku) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      final newBook = await _bukuRepository.createBuku(buku);
      _books.add(newBook);
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }

  Future<bool> updateBook(Buku buku) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      final updatedBook = await _bukuRepository.updateBuku(buku);
      final index = _books.indexWhere((element) => element.id == buku.id);
      if (index != -1) {
        _books[index] = updatedBook;
      }
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }

  Future<bool> deleteBook(String id) async {
    _setState(ViewState.loading);
    _errorMessage = null;
    try {
      await _bukuRepository.deleteBuku(id);
      _books.removeWhere((element) => element.id == id);
      _setState(ViewState.loaded);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(ViewState.error);
      return false;
    }
  }
}
