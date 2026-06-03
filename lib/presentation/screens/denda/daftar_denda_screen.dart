import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../providers/denda_provider.dart';
import '../../widgets/custom_card.dart';

class DaftarDendaScreen extends StatefulWidget {
  const DaftarDendaScreen({super.key});

  @override
  State<DaftarDendaScreen> createState() => _DaftarDendaScreenState();
}

class _DaftarDendaScreenState extends State<DaftarDendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DendaProvider>().fetchFines();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPayFinePressed(BuildContext context, dynamic fine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text('Pembayaran Denda', style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          'Konfirmasi pembayaran denda sebesar ${DateFormatter.formatRupiah(fine.jumlahDenda)} oleh ${fine.namaAnggota}?',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: TextStyle(color: AppColors.getTextSecondary(context))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Bayar Sekarang', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<DendaProvider>();
              final success = await provider.payFine(fine.id);
              
              if (context.mounted) {
                if (success) {
                  provider.fetchFines();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran denda berhasil dicatat!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Gagal memproses pembayaran'),
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
    final dendaProvider = context.watch<DendaProvider>();
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.getTextPrimary(context);

    final unpaidFines = dendaProvider.fines.where((f) => f.statusPembayaran == 'BELUM_BAYAR').toList();
    final paidFines = dendaProvider.fines.where((f) => f.statusPembayaran == 'LUNAS').toList();

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
                    'Denda Keterlambatan',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar Container
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
                    Tab(text: 'BELUM LUNAS (${unpaidFines.length})'),
                    Tab(text: 'LUNAS (${paidFines.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tab Bar View body
            Expanded(
              child: dendaProvider.state == ViewState.loading && dendaProvider.fines.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.success))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFinesListView(unpaidFines, true),
                        _buildFinesListView(paidFines, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinesListView(List<dynamic> fines, bool isUnpaid) {
    if (fines.isEmpty) {
      return Center(
        child: Text(
          isUnpaid ? 'Tidak ada tagihan denda.' : 'Tidak ada denda yang lunas.',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: fines.length,
      itemBuilder: (context, index) {
        final denda = fines[index];
        final isDark = AppColors.isDark(context);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomCard(
            child: Row(
              children: [
                // Accenting Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isUnpaid ? AppColors.warning : AppColors.success).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: isUnpaid ? AppColors.warning : AppColors.success,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Fine Details text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        denda.namaAnggota,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buku: ${denda.judulBuku}',
                        style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormatter.formatRupiah(denda.jumlahDenda),
                        style: TextStyle(
                          color: isUnpaid ? AppColors.error : AppColors.success,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Status Badge or Pay Button
                if (isUnpaid)
                  ElevatedButton(
                    onPressed: () => _onPayFinePressed(context, denda),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Bayar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'LUNAS',
                      style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
