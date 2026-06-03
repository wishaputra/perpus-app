import '../../domain/entities/buku.dart';
import '../../domain/entities/peminjaman.dart';
import '../../domain/entities/denda.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _initData();
  }

  final List<Buku> books = [];
  final List<Peminjaman> loans = [];
  final List<Denda> fines = [];

  void _initData() {
    // Seed Books
    books.addAll([
      Buku(
        id: 'B001',
        judul: 'Harry Potter and the Sorcerer\'s Stone',
        isbn: '9780590353427',
        penulis: 'J.K. Rowling',
        penerbit: 'Scholastic',
        jenis: 'Novel Fantasi',
        tahunTerbit: 1998,
        stok: 5,
        deskripsi: 'Buku pertama dalam seri Harry Potter yang menceritakan tentang perkenalan Harry di dunia sihir Hogwarts.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/81YOuOGFCFL.jpg',
      ),
      Buku(
        id: 'B002',
        judul: 'Clean Code: A Handbook of Agile Software Craftsmanship',
        isbn: '9780132350884',
        penulis: 'Robert C. Martin',
        penerbit: 'Prentice Hall',
        jenis: 'Komputer & IT',
        tahunTerbit: 2008,
        stok: 2,
        deskripsi: 'Buku wajib bagi setiap developer yang ingin menulis kode yang bersih, mudah dipelihara, dan efisien.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/41xShfaR2FL._SX396_BO1,204,203,200_.jpg',
      ),
      Buku(
        id: 'B003',
        judul: 'Introduction to Algorithms',
        isbn: '9780262033848',
        penulis: 'Thomas H. Cormen',
        penerbit: 'MIT Press',
        jenis: 'Edukasi / Sains',
        tahunTerbit: 2009,
        stok: 3,
        deskripsi: 'Buku referensi komprehensif mengenai analisis dan perancangan algoritma komputer.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/41vOQDbrrGL._SX385_BO1,204,203,200_.jpg',
      ),
      Buku(
        id: 'B004',
        judul: 'The Pragmatic Programmer',
        isbn: '9780135957059',
        penulis: 'David Thomas',
        penerbit: 'Addison-Wesley',
        jenis: 'Komputer & IT',
        tahunTerbit: 2019,
        stok: 4,
        deskripsi: 'Panduan pragmatis untuk meningkatkan keahlian pemrograman dan karir sebagai rekayasawan perangkat lunak.',
        coverUrl: 'https://images-na.ssl-images-amazon.com/images/I/51IA4hTJHFL._SX386_BO1,204,203,200_.jpg',
      ),
    ]);

    // Seed Loans
    loans.addAll([
      Peminjaman(
        id: 'L001',
        namaAnggota: 'Budi Santoso',
        nim: '210102045',
        buku: books[0],
        tanggalPinjam: DateTime.now().subtract(const Duration(days: 10)),
        tanggalKembali: DateTime.now().subtract(const Duration(days: 3)),
        status: 'DIPINJAM',
        dendaTerakumulasi: 0,
      ),
      Peminjaman(
        id: 'L002',
        namaAnggota: 'Siti Rahmawati',
        nim: '210102088',
        buku: books[1],
        tanggalPinjam: DateTime.now().subtract(const Duration(days: 8)),
        tanggalKembali: DateTime.now().subtract(const Duration(days: 1)),
        tanggalPengembalian: DateTime.now(),
        status: 'KEMBALI',
        dendaTerakumulasi: 5000,
      ),
    ]);

    // Seed Fines
    fines.addAll([
      Denda(
        id: 'F001',
        peminjamanId: 'L002',
        namaAnggota: 'Siti Rahmawati',
        judulBuku: books[1].judul,
        jumlahDenda: 5000,
        statusPembayaran: 'BELUM_BAYAR',
        tanggalDibuat: DateTime.now(),
      ),
    ]);
  }
}
