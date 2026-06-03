import '../../domain/entities/denda.dart';

class DendaModel extends Denda {
  DendaModel({
    required super.id,
    required super.peminjamanId,
    required super.namaAnggota,
    required super.judulBuku,
    required super.jumlahDenda,
    required super.statusPembayaran,
    required super.tanggalDibuat,
  });

  factory DendaModel.fromJson(Map<String, dynamic> json) {
    return DendaModel(
      id: json['id']?.toString() ?? '',
      peminjamanId: json['peminjaman_id']?.toString() ?? '',
      namaAnggota: json['nama_anggota'] ?? '',
      judulBuku: json['judul_buku'] ?? '',
      jumlahDenda: json['jumlah_denda'] != null 
          ? double.tryParse(json['jumlah_denda'].toString()) ?? 0.0 
          : 0.0,
      statusPembayaran: json['status_pembayaran'] ?? 'BELUM_BAYAR',
      tanggalDibuat: json['tanggal_dibuat'] != null 
          ? DateTime.parse(json['tanggal_dibuat'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'nama_anggota': namaAnggota,
      'judul_buku': judulBuku,
      'jumlah_denda': jumlahDenda,
      'status_pembayaran': statusPembayaran,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
    };
  }
}
