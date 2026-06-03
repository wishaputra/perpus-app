import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/denda.dart';
import '../../domain/repositories/denda_repository.dart';
import '../datasources/mock_database.dart';
import '../models/denda_model.dart';

class DendaRepositoryImpl implements DendaRepository {
  final ApiClient _apiClient;
  final MockDatabase _mockDb = MockDatabase();

  DendaRepositoryImpl(this._apiClient);

  @override
  Future<List<Denda>> getAllDenda() async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockDb.fines;
    } else {
      try {
        final response = await _apiClient.dio.get('/denda');
        if (response.statusCode == 200) {
          final List listJson = response.data['data'] ?? response.data;
          return listJson.map((e) => DendaModel.fromJson(e)).toList();
        }
        throw Exception('Gagal memuat daftar denda');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Kesalahan koneksi');
      }
    }
  }

  @override
  Future<Denda> bayarDenda(String id) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 700));
      final index = _mockDb.fines.indexWhere((element) => element.id == id);
      if (index == -1) {
        throw Exception('Denda tidak ditemukan');
      }

      final targetFine = _mockDb.fines[index];
      final updatedFine = Denda(
        id: targetFine.id,
        peminjamanId: targetFine.peminjamanId,
        namaAnggota: targetFine.namaAnggota,
        judulBuku: targetFine.judulBuku,
        jumlahDenda: targetFine.jumlahDenda,
        statusPembayaran: 'LUNAS',
        tanggalDibuat: targetFine.tanggalDibuat,
      );

      _mockDb.fines[index] = updatedFine;
      return updatedFine;
    } else {
      try {
        final response = await _apiClient.dio.post('/denda/bayar/$id');
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return DendaModel.fromJson(data);
        }
        throw Exception('Gagal melakukan pembayaran denda');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memproses pembayaran');
      }
    }
  }
}
