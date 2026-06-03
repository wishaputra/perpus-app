import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/buku.dart';
import '../../domain/repositories/buku_repository.dart';
import '../datasources/mock_database.dart';
import '../models/buku_model.dart';

class BukuRepositoryImpl implements BukuRepository {
  final ApiClient _apiClient;
  final MockDatabase _mockDb = MockDatabase();

  BukuRepositoryImpl(this._apiClient);

  @override
  Future<List<Buku>> getAllBuku() async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockDb.books;
    } else {
      try {
        final response = await _apiClient.dio.get('/buku');
        if (response.statusCode == 200) {
          final List listJson = response.data['data'] ?? response.data;
          return listJson.map((e) => BukuModel.fromJson(e)).toList();
        }
        throw Exception('Gagal memuat daftar buku');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Kesalahan koneksi');
      }
    }
  }

  @override
  Future<Buku> getBukuById(String id) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockDb.books.firstWhere(
        (element) => element.id == id,
        orElse: () => throw Exception('Buku tidak ditemukan'),
      );
    } else {
      try {
        final response = await _apiClient.dio.get('/buku/$id');
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return BukuModel.fromJson(data);
        }
        throw Exception('Buku tidak ditemukan');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Kesalahan koneksi');
      }
    }
  }

  @override
  Future<Buku> createBuku(Buku buku) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final newBuku = buku.copyWith(
        id: 'B00${_mockDb.books.length + 1}',
        coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
      );
      _mockDb.books.add(newBuku);
      return newBuku;
    } else {
      try {
        final bookModel = BukuModel.fromEntity(buku);
        final response = await _apiClient.dio.post('/buku', data: bookModel.toJson());
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return BukuModel.fromJson(data);
        }
        throw Exception('Gagal menyimpan buku baru');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal menyimpan data');
      }
    }
  }

  @override
  Future<Buku> updateBuku(Buku buku) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final index = _mockDb.books.indexWhere((element) => element.id == buku.id);
      if (index != -1) {
        _mockDb.books[index] = buku;
        return buku;
      }
      throw Exception('Buku tidak ditemukan');
    } else {
      try {
        final bookModel = BukuModel.fromEntity(buku);
        final response = await _apiClient.dio.put('/buku/${buku.id}', data: bookModel.toJson());
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return BukuModel.fromJson(data);
        }
        throw Exception('Gagal mengubah data buku');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal mengubah data');
      }
    }
  }

  @override
  Future<void> deleteBuku(String id) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockDb.books.removeWhere((element) => element.id == id);
      return;
    } else {
      try {
        final response = await _apiClient.dio.delete('/buku/$id');
        if (response.statusCode != 200) {
          throw Exception('Gagal menghapus buku');
        }
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal menghapus data');
      }
    }
  }
}
