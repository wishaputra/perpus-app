import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/buku.dart';
import '../../providers/buku_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import 'form_buku_screen.dart';

class DetailBukuScreen extends StatelessWidget {
  final String bookId;

  const DetailBukuScreen({super.key, required this.bookId});

  void _onDeletePressed(BuildContext context, Buku book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text('Hapus Buku', style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${book.judul}" secara permanen?',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: TextStyle(color: AppColors.getTextSecondary(context))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Ya, Hapus', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<BukuProvider>().deleteBook(book.id);
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buku berhasil dihapus!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus buku.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BukuProvider>();
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.getTextPrimary(context);
    
    final Buku book;
    try {
      book = bookProvider.books.firstWhere((element) => element.id == bookId);
    } catch (_) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(context),
        appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton()),
        body: Center(
          child: Text('Buku tidak ditemukan.', style: TextStyle(color: textPrimary)),
        ),
      );
    }

    final hasStock = book.stok > 0;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getSurface(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.getBorder(context)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Detail Buku',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getSurface(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.getBorder(context)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                      onPressed: () => _onDeletePressed(context, book),
                    ),
                  ),
                ],
              ),
            ),

            // Detail Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover Preview
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            book.coverUrl ?? 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                            width: 140,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140,
                              height: 200,
                              color: AppColors.getSurface(context),
                              child: Icon(Icons.book_rounded, color: AppColors.getTextSecondary(context), size: 64),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title & Author & Availability
                    Center(
                      child: Column(
                        children: [
                          Text(
                            book.judul,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Penulis: ${book.penulis}',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: (hasStock ? AppColors.success : AppColors.error).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (hasStock ? AppColors.success : AppColors.error).withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              hasStock ? 'TERSEDIA (${book.stok} Buku)' : 'STOK HABIS',
                              style: TextStyle(
                                color: hasStock ? AppColors.success : AppColors.error,
                                fontSize: 11,
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Metadata Grid Box
                    Text(
                      'Informasi Buku',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        children: [
                          _buildInfoItem(context, 'ISBN', book.isbn),
                          _buildInfoItem(context, 'Penerbit', book.penerbit),
                          _buildInfoItem(context, 'Jenis Buku', book.jenis),
                          _buildInfoItem(context, 'Tahun Terbit', book.tahunTerbit.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Synopsis / Description
                    Text(
                      'Deskripsi / Sinopsis',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        book.deskripsi.isEmpty 
                            ? 'Tidak ada deskripsi untuk buku ini.' 
                            : book.deskripsi,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Edit Button Action (B&W inverted color button for distinct action)
                    CustomButton(
                      text: 'UBAH DATA BUKU',
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      textColor: isDark ? Colors.black : Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormBukuScreen(book: book),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
