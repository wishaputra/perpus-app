class Denda {
  final String id;
  final String peminjamanId;
  final String namaAnggota;
  final String judulBuku;
  final double jumlahDenda;
  final String statusPembayaran; // 'BELUM_BAYAR' atau 'LUNAS'
  final DateTime tanggalDibuat;

  Denda({
    required this.id,
    required this.peminjamanId,
    required this.namaAnggota,
    required this.judulBuku,
    required this.jumlahDenda,
    required this.statusPembayaran,
    required this.tanggalDibuat,
  });
}
