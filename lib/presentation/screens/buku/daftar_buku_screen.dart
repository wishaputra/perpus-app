import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/view_state.dart';
import '../../providers/buku_provider.dart';
import '../../widgets/custom_card.dart';
import 'detail_buku_screen.dart';
import 'form_buku_screen.dart';

class DaftarBukuScreen extends StatefulWidget {
  const DaftarBukuScreen({super.key});

  @override
  State<DaftarBukuScreen> createState() => _DaftarBukuScreenState();
}

class _DaftarBukuScreenState extends State<DaftarBukuScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BukuProvider>().fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BukuProvider>();
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.getTextPrimary(context);

    // Filter books based on search query
    final filteredBooks = bookProvider.books.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.judul.toLowerCase().contains(query) ||
          book.penulis.toLowerCase().contains(query) ||
          book.jenis.toLowerCase().contains(query) ||
          book.isbn.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
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
                  const SizedBox(width: 16),
                  Text(
                    'Katalog Buku',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textPrimary),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, jenis, atau ISBN...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.getTextSecondary(context)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textPrimary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Body Content
            Expanded(
              child: bookProvider.state == ViewState.loading && bookProvider.books.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.success),
                    )
                  : filteredBooks.isEmpty
                      ? Center(
                          child: Text(
                            'Buku tidak ditemukan.',
                            style: TextStyle(color: AppColors.getTextSecondary(context)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildBookCard(context, book),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add_rounded, color: isDark ? Colors.black : Colors.white, size: 28),
        onPressed: () {
          final provider = context.read<BukuProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormBukuScreen()),
          ).then((_) {
            provider.fetchBooks();
          });
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, dynamic book) {
    final hasStock = book.stok > 0;
    final isDark = AppColors.isDark(context);
    
    return InkWell(
      onTap: () {
        final provider = context.read<BukuProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBukuScreen(bookId: book.id),
          ),
        ).then((_) {
          provider.fetchBooks();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Image Mock
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 96,
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                child: Image.network(
                  book.coverUrl ?? 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.book_rounded, color: AppColors.getTextSecondary(context), size: 28),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Book Details text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book category text
                  Text(
                    book.jenis.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Book title
                  Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Author
                  Text(
                    'Oleh ${book.penulis}',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Stock Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (hasStock ? AppColors.success : AppColors.error).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (hasStock ? AppColors.success : AppColors.error).withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      hasStock ? 'Tersedia: ${book.stok} Buku' : 'Stok Kosong',
                      style: TextStyle(
                        color: hasStock ? AppColors.success : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
