import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/buku_provider.dart';
import '../../providers/peminjaman_provider.dart';
import '../../providers/denda_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';
import '../auth/login_screen.dart';
import '../buku/daftar_buku_screen.dart';
import '../peminjaman/daftar_peminjaman_screen.dart';
import '../peminjaman/form_peminjaman_screen.dart';
import '../denda/daftar_denda_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    context.read<BukuProvider>().fetchBooks();
    context.read<PeminjamanProvider>().fetchLoans();
    context.read<DendaProvider>().fetchFines();
  }

  void _onLogoutPressed(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authUser = context.watch<AuthProvider>().user;
    final bookProvider = context.watch<BukuProvider>();
    final loanProvider = context.watch<PeminjamanProvider>();
    final fineProvider = context.watch<DendaProvider>();

    final isDark = themeProvider.isDarkMode;
    final textPrimary = AppColors.getTextPrimary(context);

    // Calculate metrics
    final totalBooks = bookProvider.books.length.toString();
    final activeLoans = loanProvider.loans.where((l) => l.status == 'DIPINJAM').length;
    final totalFines = fineProvider.fines
        .where((f) => f.statusPembayaran == 'BELUM_BAYAR')
        .fold(0.0, (sum, item) => sum + item.jumlahDenda);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          color: isDark ? Colors.black : Colors.white,
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Mockup Style: Left menu/back, Center title, Right settings & Avatar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Menu Icon
                    GestureDetector(
                      onTap: () => _onLogoutPressed(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.getBorder(context)),
                        ),
                        child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      ),
                    ),
                    
                    // Center Screen Title
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Right Settings & Profile Avatar
                    Row(
                      children: [
                        // Theme Toggle Icon
                        GestureDetector(
                          onTap: () => themeProvider.toggleTheme(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(context),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.getBorder(context)),
                            ),
                            child: Icon(
                              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
                              color: textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Circular Avatar Silhouette
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.getSurface(context),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.getBorder(context), width: 1.5),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.getTextPrimary(context),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Greeting & Big Bold Headline
                Text(
                  'Halo, ${authUser?.nama ?? 'Pegawai'}',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perpustakaan Kita',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Navigation Pills / Category Selector (Mockup Style)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPill('Semua'),
                      const SizedBox(width: 8),
                      _buildPill('Katalog'),
                      const SizedBox(width: 8),
                      _buildPill('Sirkulasi'),
                      const SizedBox(width: 8),
                      _buildPill('Keuangan'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Conditional Content Sections based on Active Pill
                if (_activeCategory == 'Semua') ...[
                  // Hero Card (Large Bold Metric, inspired by mock layout)
                  _buildHeroCard(context, activeLoans),
                  const SizedBox(height: 20),

                  // Pastel Stats Cards List (Clean colors, matching middle phone mockup)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Koleksi Buku',
                          value: totalBooks,
                          icon: Icons.book_rounded,
                          backgroundColor: AppColors.greenPastelBg,
                          textColor: AppColors.greenPastelText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Total Denda',
                          value: DateFormatter.formatRupiah(totalFines),
                          icon: Icons.receipt_long_rounded,
                          backgroundColor: AppColors.orangePastelBg,
                          textColor: AppColors.orangePastelText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent Active Loans header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peminjaman Aktif',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DaftarPeminjamanScreen()),
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // List of active loans
                  if (loanProvider.loans.isEmpty)
                    const CustomCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Tidak ada peminjaman aktif.',
                            style: TextStyle(color: AppColors.textSecondaryDark),
                          ),
                        ),
                      ),
                    )
                  else
                    ...loanProvider.loans
                        .where((l) => l.status == 'DIPINJAM')
                        .take(3)
                        .map((loan) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildRecentLoanCard(context, loan),
                            )),
                ] else if (_activeCategory == 'Katalog') ...[
                  // Directly show Catalog Quick Access
                  _buildSectionPanel(
                    title: 'Kelola Katalog Buku',
                    description: 'Tambahkan, ubah, atau hapus buku pustaka.',
                    buttonText: 'Buka Katalog Buku',
                    color: AppColors.greenPastelBg,
                    textColor: AppColors.greenPastelText,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarBukuScreen())),
                  ),
                ] else if (_activeCategory == 'Sirkulasi') ...[
                  // Directly show Loans Quick Access
                  _buildSectionPanel(
                    title: 'Peminjaman & Kembali',
                    description: 'Catat transaksi peminjaman baru mahasiswa atau proses pengembalian buku.',
                    buttonText: 'Buka Sirkulasi Peminjaman',
                    color: AppColors.purplePastelBg,
                    textColor: AppColors.purplePastelText,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarPeminjamanScreen())),
                  ),
                ] else if (_activeCategory == 'Keuangan') ...[
                  // Directly show Fines Quick Access
                  _buildSectionPanel(
                    title: 'Denda Keterlambatan',
                    description: 'Pantau laporan denda terlambat dan lakukan pencatatan pembayaran.',
                    buttonText: 'Buka Laporan Denda',
                    color: AppColors.orangePastelBg,
                    textColor: AppColors.orangePastelText,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarDendaScreen())),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String name) {
    final isActive = _activeCategory == name;
    final isDark = AppColors.isDark(context);
    
    final activeBg = isDark ? Colors.white : Colors.black;
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveBg = AppColors.getSurface(context);
    final inactiveText = AppColors.getTextSecondary(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = name;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.getBorder(context),
            width: 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isActive ? activeText : inactiveText,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, int activeLoans) {
    final isDark = AppColors.isDark(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sirkulasi Hari Ini',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transaksi\nPeminjaman',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FormPeminjamanScreen()),
                    ).then((_) => _refreshData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pinjam Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Big bold display counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  activeLoans.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPanel({
    required String title,
    required String description,
    required String buttonText,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return CustomCard(
      backgroundColor: color,
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: color,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLoanCard(BuildContext context, dynamic loan) {
    final isOverdue = loan.isOverdue;
    final isDark = AppColors.isDark(context);
    
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loan.buku.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isOverdue ? AppColors.error : AppColors.warning).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isOverdue ? AppColors.error : AppColors.warning).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        isOverdue ? 'TERLAMBAT' : 'DIPINJAM',
                        style: TextStyle(
                          color: isOverdue ? AppColors.error : AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Peminjam: ${loan.namaAnggota} (${loan.nim})',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Batas Kembali: ${DateFormatter.formatShort(loan.tanggalKembali)}',
                  style: TextStyle(
                    color: isOverdue ? AppColors.error : AppColors.getTextSecondary(context),
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action button to Return directly
          IconButton(
            icon: Icon(Icons.assignment_return_rounded, color: isDark ? Colors.white : Colors.black),
            tooltip: 'Kembalikan Buku',
            onPressed: () => _showReturnConfirmation(context, loan),
          ),
        ],
      ),
    );
  }

  void _showReturnConfirmation(BuildContext context, dynamic loan) {
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
          'Apakah Anda yakin ingin menerima pengembalian buku "${loan.buku.judul}" oleh ${loan.namaAnggota}?',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: TextStyle(color: AppColors.getTextSecondary(context))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Ya, Kembalikan', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<PeminjamanProvider>();
              final success = await provider.returnBook(loan.id);
              
              if (context.mounted) {
                if (success) {
                  _refreshData();
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
}
