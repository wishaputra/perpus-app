import '../../domain/entities/peminjaman.dart';
import 'buku_model.dart';

class PeminjamanModel extends Peminjaman {
  PeminjamanModel({
    required super.id,
    required super.namaAnggota,
    required super.nim,
    required super.buku,
    required super.tanggalPinjam,
    required super.tanggalKembali,
    super.tanggalPengembalian,
    required super.status,
    required super.dendaTerakumulasi,
  });

  factory PeminjamanModel.fromJson(Map<String, dynamic> json) {
    return PeminjamanModel(
      id: json['id']?.toString() ?? '',
      namaAnggota: json['nama_anggota'] ?? '',
      nim: json['nim'] ?? '',
      buku: BukuModel.fromJson(json['buku'] ?? {}),
      tanggalPinjam: json['tanggal_pinjam'] != null 
          ? DateTime.parse(json['tanggal_pinjam'].toString()) 
          : DateTime.now(),
      tanggalKembali: json['tanggal_kembali'] != null 
          ? DateTime.parse(json['tanggal_kembali'].toString()) 
          : DateTime.now().add(const Duration(days: 7)),
      tanggalPengembalian: json['tanggal_pengembalian'] != null 
          ? DateTime.parse(json['tanggal_pengembalian'].toString()) 
          : null,
      status: json['status'] ?? 'DIPINJAM',
      dendaTerakumulasi: json['denda_terakumulasi'] != null 
          ? double.tryParse(json['denda_terakumulasi'].toString()) ?? 0.0 
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'nim': nim,
      'buku': BukuModel.fromEntity(buku).toJson(),
      'tanggal_pinjam': tanggalPinjam.toIso8601String(),
      'tanggal_kembali': tanggalKembali.toIso8601String(),
      'tanggal_pengembalian': tanggalPengembalian?.toIso8601String(),
      'status': status,
      'denda_terakumulasi': dendaTerakumulasi,
    };
  }
}
