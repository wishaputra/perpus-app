import '../entities/peminjaman.dart';

abstract class PeminjamanRepository {
  Future<List<Peminjaman>> getAllPeminjaman();
  Future<Peminjaman> createPeminjaman({
    required String namaAnggota,
    required String nim,
    required String bukuId,
    required DateTime tanggalKembali,
  });
  Future<Peminjaman> kembalikanBuku(String id);
}
