import '../../domain/entities/buku.dart';

class BukuModel extends Buku {
  BukuModel({
    required super.id,
    required super.judul,
    required super.isbn,
    required super.penulis,
    required super.penerbit,
    required super.jenis,
    required super.tahunTerbit,
    required super.stok,
    required super.deskripsi,
    super.coverUrl,
  });

  factory BukuModel.fromJson(Map<String, dynamic> json) {
    return BukuModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? '',
      isbn: json['isbn'] ?? '',
      penulis: json['penulis'] ?? '',
      penerbit: json['penerbit'] ?? '',
      jenis: json['jenis'] ?? '',
      tahunTerbit: json['tahun_terbit'] != null 
          ? int.tryParse(json['tahun_terbit'].toString()) ?? 2020 
          : 2020,
      stok: json['stok'] != null 
          ? int.tryParse(json['stok'].toString()) ?? 0 
          : 0,
      deskripsi: json['deskripsi'] ?? '',
      coverUrl: json['cover_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isbn': isbn,
      'penulis': penulis,
      'penerbit': penerbit,
      'jenis': jenis,
      'tahun_terbit': tahunTerbit,
      'stok': stok,
      'deskripsi': deskripsi,
      'cover_url': coverUrl,
    };
  }

  factory BukuModel.fromEntity(Buku entity) {
    return BukuModel(
      id: entity.id,
      judul: entity.judul,
      isbn: entity.isbn,
      penulis: entity.penulis,
      penerbit: entity.penerbit,
      jenis: entity.jenis,
      tahunTerbit: entity.tahunTerbit,
      stok: entity.stok,
      deskripsi: entity.deskripsi,
      coverUrl: entity.coverUrl,
    );
  }
}
