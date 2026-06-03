import 'buku.dart';

class Peminjaman {
  final String id;
  final String namaAnggota;
  final String nim; // Nomor Induk Mahasiswa / No Anggota
  final Buku buku;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final DateTime? tanggalPengembalian;
  final String status; // 'DIPINJAM' atau 'KEMBALI'
  final double dendaTerakumulasi;

  Peminjaman({
    required this.id,
    required this.namaAnggota,
    required this.nim,
    required this.buku,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    this.tanggalPengembalian,
    required this.status,
    required this.dendaTerakumulasi,
  });

  bool get isOverdue => DateTime.now().isAfter(tanggalKembali) && status == 'DIPINJAM';
  
  int get overdueDays {
    if (status == 'KEMBALI') {
      if (tanggalPengembalian != null && tanggalPengembalian!.isAfter(tanggalKembali)) {
        return tanggalPengembalian!.difference(tanggalKembali).inDays;
      }
      return 0;
    }
    if (DateTime.now().isAfter(tanggalKembali)) {
      return DateTime.now().difference(tanggalKembali).inDays;
    }
    return 0;
  }
}
