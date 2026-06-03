class Buku {
  final String id;
  final String judul;
  final String isbn;
  final String penulis;
  final String penerbit;
  final String jenis;
  final int tahunTerbit;
  final int stok;
  final String deskripsi;
  final String? coverUrl;

  Buku({
    required this.id,
    required this.judul,
    required this.isbn,
    required this.penulis,
    required this.penerbit,
    required this.jenis,
    required this.tahunTerbit,
    required this.stok,
    required this.deskripsi,
    this.coverUrl,
  });

  Buku copyWith({
    String? id,
    String? judul,
    String? isbn,
    String? penulis,
    String? penerbit,
    String? jenis,
    int? tahunTerbit,
    int? stok,
    String? deskripsi,
    String? coverUrl,
  }) {
    return Buku(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isbn: isbn ?? this.isbn,
      penulis: penulis ?? this.penulis,
      penerbit: penerbit ?? this.penerbit,
      jenis: jenis ?? this.jenis,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      stok: stok ?? this.stok,
      deskripsi: deskripsi ?? this.deskripsi,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
