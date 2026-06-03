import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/peminjaman.dart';
import '../../domain/entities/denda.dart';
import '../../domain/repositories/peminjaman_repository.dart';
import '../datasources/mock_database.dart';
import '../models/peminjaman_model.dart';

class PeminjamanRepositoryImpl implements PeminjamanRepository {
  final ApiClient _apiClient;
  final MockDatabase _mockDb = MockDatabase();

  PeminjamanRepositoryImpl(this._apiClient);

  @override
  Future<List<Peminjaman>> getAllPeminjaman() async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockDb.loans;
    } else {
      try {
        final response = await _apiClient.dio.get('/peminjaman');
        if (response.statusCode == 200) {
          final List listJson = response.data['data'] ?? response.data;
          return listJson.map((e) => PeminjamanModel.fromJson(e)).toList();
        }
        throw Exception('Gagal memuat riwayat peminjaman');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Kesalahan koneksi');
      }
    }
  }

  @override
  Future<Peminjaman> createPeminjaman({
    required String namaAnggota,
    required String nim,
    required String bukuId,
    required DateTime tanggalKembali,
  }) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final bookIndex = _mockDb.books.indexWhere((element) => element.id == bukuId);
      if (bookIndex == -1) {
        throw Exception('Buku tidak ditemukan');
      }
      
      final targetBook = _mockDb.books[bookIndex];
      if (targetBook.stok <= 0) {
        throw Exception('Stok buku sedang kosong');
      }
      
      // Update stok buku
      _mockDb.books[bookIndex] = targetBook.copyWith(stok: targetBook.stok - 1);

      final newLoan = Peminjaman(
        id: 'L00${_mockDb.loans.length + 1}',
        namaAnggota: namaAnggota,
        nim: nim,
        buku: _mockDb.books[bookIndex],
        tanggalPinjam: DateTime.now(),
        tanggalKembali: tanggalKembali,
        status: 'DIPINJAM',
        dendaTerakumulasi: 0.0,
      );

      _mockDb.loans.add(newLoan);
      return newLoan;
    } else {
      try {
        final response = await _apiClient.dio.post('/peminjaman', data: {
          'nama_anggota': namaAnggota,
          'nim': nim,
          'buku_id': bukuId,
          'tanggal_kembali': tanggalKembali.toIso8601String(),
        });
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return PeminjamanModel.fromJson(data);
        }
        throw Exception('Gagal membuat peminjaman');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal membuat transaksi');
      }
    }
  }

  @override
  Future<Peminjaman> kembalikanBuku(String id) async {
    if (ApiClient.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      final loanIndex = _mockDb.loans.indexWhere((element) => element.id == id);
      if (loanIndex == -1) {
        throw Exception('Transaksi peminjaman tidak ditemukan');
      }

      final targetLoan = _mockDb.loans[loanIndex];
      if (targetLoan.status == 'KEMBALI') {
        throw Exception('Buku sudah dikembalikan sebelumnya');
      }

      // Hitung keterlambatan & denda (Rp 2000 per hari terlambat)
      final returnDate = DateTime.now();
      double computedFine = 0.0;
      if (returnDate.isAfter(targetLoan.tanggalKembali)) {
        final days = returnDate.difference(targetLoan.tanggalKembali).inDays;
        if (days > 0) {
          computedFine = days * 2000.0;
        }
      }

      // Restock buku
      final bookIndex = _mockDb.books.indexWhere((element) => element.id == targetLoan.buku.id);
      if (bookIndex != -1) {
        final b = _mockDb.books[bookIndex];
        _mockDb.books[bookIndex] = b.copyWith(stok: b.stok + 1);
      }

      final updatedLoan = Peminjaman(
        id: targetLoan.id,
        namaAnggota: targetLoan.namaAnggota,
        nim: targetLoan.nim,
        buku: targetLoan.buku,
        tanggalPinjam: targetLoan.tanggalPinjam,
        tanggalKembali: targetLoan.tanggalKembali,
        tanggalPengembalian: returnDate,
        status: 'KEMBALI',
        dendaTerakumulasi: computedFine,
      );

      _mockDb.loans[loanIndex] = updatedLoan;

      // Jika ada denda, catat ke MockDatabase denda
      if (computedFine > 0) {
        _mockDb.fines.add(
          Denda(
            id: 'F00${_mockDb.fines.length + 1}',
            peminjamanId: updatedLoan.id,
            namaAnggota: updatedLoan.namaAnggota,
            judulBuku: updatedLoan.buku.judul,
            jumlahDenda: computedFine,
            statusPembayaran: 'BELUM_BAYAR',
            tanggalDibuat: DateTime.now(),
          ),
        );
      }

      return updatedLoan;
    } else {
      try {
        final response = await _apiClient.dio.post('/peminjaman/kembali/$id');
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          return PeminjamanModel.fromJson(data);
        }
        throw Exception('Gagal melakukan pengembalian');
      } on DioException catch (e) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memproses pengembalian');
      }
    }
  }
}
