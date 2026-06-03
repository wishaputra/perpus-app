import '../entities/buku.dart';

abstract class BukuRepository {
  Future<List<Buku>> getAllBuku();
  Future<Buku> getBukuById(String id);
  Future<Buku> createBuku(Buku buku);
  Future<Buku> updateBuku(Buku buku);
  Future<void> deleteBuku(String id);
}
