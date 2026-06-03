import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/custom_card.dart';
import 'form_peminjaman_screen.dart';

class DaftarPeminjamanScreen extends StatefulWidget {
  const DaftarPeminjamanScreen({super.key});

  @override
  State<DaftarPeminjamanScreen> createState() => _DaftarPeminjamanScreenState();
}

class _DaftarPeminjamanScreenState extends State<DaftarPeminjamanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeminjamanProvider>().fetchLoans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onReturnPressed(BuildContext context, dynamic loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text('Konfirmasi Pengembalian', style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          'Apakah Anda yakin ingin menerima pengembalian buku "${loan.buku.judul}"?',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: TextStyle(color: AppColors.getTextSecondary(context))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Ya, Kembalikan', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<PeminjamanProvider>();
              final success = await provider.returnBook(loan.id);
              
              if (context.mounted) {
                if (success) {
                  provider.fetchLoans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buku berhasil dikembalikan!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Gagal memproses pengembalian'),
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
    final loanProvider = context.watch<PeminjamanProvider>();
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.getTextPrimary(context);

    final activeLoans = loanProvider.loans.where((l) => l.status == 'DIPINJAM').toList();
    final completedLoans = loanProvider.loans.where((l) => l.status == 'KEMBALI').toList();

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
                    'Peminjaman Buku',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar Container (Styled pills-style tab bar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.getBorder(context)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: isDark ? Colors.black : Colors.white,
                  unselectedLabelColor: AppColors.getTextSecondary(context),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'AKTIF (${activeLoans.length})'),
                    Tab(text: 'RIWAYAT (${completedLoans.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tab Bar View body
            Expanded(
              child: loanProvider.state == ViewState.loading && loanProvider.loans.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.success))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoanListView(activeLoans, true),
                        _buildLoanListView(completedLoans, false),
                      ],
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
          final provider = context.read<PeminjamanProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPeminjamanScreen()),
          ).then((_) {
            provider.fetchLoans();
          });
        },
      ),
    );
  }

  Widget _buildLoanListView(List<dynamic> loans, bool isActive) {
    if (loans.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'Tidak ada peminjaman aktif.' : 'Tidak ada riwayat peminjaman.',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        final isOverdue = loan.isOverdue;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight indicator bar instead of colored card borders
                Container(
                  width: 4,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? (isOverdue ? AppColors.error : AppColors.warning)
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.buku.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Peminjam: ${loan.namaAnggota} (${loan.nim})',
                        style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      
                      // Dates row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded, 
                            color: AppColors.getTextSecondary(context).withOpacity(0.6), 
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormatter.formatShort(loan.tanggalPinjam)} - ${DateFormatter.formatShort(loan.tanggalKembali)}',
                            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
                          ),
                        ],
                      ),
                      if (!isActive && loan.tanggalPengembalian != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.assignment_turned_in_rounded, color: AppColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Kembali: ${DateFormatter.formatShort(loan.tanggalPengembalian!)}',
                              style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Right Action or Status
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isActive)
                      IconButton(
                        icon: Icon(Icons.assignment_return_rounded, color: AppColors.getTextPrimary(context)),
                        tooltip: 'Kembalikan Buku',
                        onPressed: () => _onReturnPressed(context, loan),
                      )
                    else if (loan.dendaTerakumulasi > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.error.withOpacity(0.25)),
                        ),
                        child: const Text(
                          'Denda Late',
                          style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
