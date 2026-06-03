import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../providers/buku_provider.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_card.dart';

class FormPeminjamanScreen extends StatefulWidget {
  const FormPeminjamanScreen({super.key});

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  
  String? _selectedBookId;
  DateTime _tanggalKembali = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BukuProvider>().fetchBooks();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  void _onPickDatePressed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKembali,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.getPrimary(context),
              onPrimary: AppColors.getOnPrimary(context),
              surface: AppColors.getSurface(context),
              onSurface: AppColors.getTextPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalKembali = picked;
      });
    }
  }

  void _onSavePressed() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBookId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih buku yang ingin dipinjam'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final loanProvider = context.read<PeminjamanProvider>();
      final success = await loanProvider.createLoan(
        namaAnggota: _namaController.text.trim(),
        nim: _nimController.text.trim(),
        bukuId: _selectedBookId!,
        tanggalKembali: _tanggalKembali,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil dicatat!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loanProvider.errorMessage ?? 'Gagal memproses transaksi peminjaman.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BukuProvider>();
    final loanProvider = context.watch<PeminjamanProvider>();
    final textPrimary = AppColors.getTextPrimary(context);

    // List of books with stock > 0
    final availableBooks = bookProvider.books.where((b) => b.stok > 0).toList();

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
                    'Pencatatan Pinjam Baru',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: CustomCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Peminjaman',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nama Peminjam
                        CustomTextField(
                          controller: _namaController,
                          labelText: 'Nama Anggota',
                          hintText: 'Nama lengkap peminjam',
                          prefixIcon: Icons.badge_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Nama harus diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        // NIM Peminjam
                        CustomTextField(
                          controller: _nimController,
                          labelText: 'NIM / Nomor Anggota',
                          hintText: 'Nomor Induk Mahasiswa atau ID Anggota',
                          prefixIcon: Icons.assignment_ind_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'NIM harus diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        // Book Dropdown Selector
                        Text(
                          'Pilih Buku',
                          style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedBookId,
                          style: TextStyle(color: textPrimary),
                          dropdownColor: AppColors.getSurface(context),
                          hint: Text('Pilih buku dari daftar', style: TextStyle(color: AppColors.getTextSecondary(context).withOpacity(0.5))),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.book_rounded, color: AppColors.getTextSecondary(context)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: availableBooks.map((book) {
                            return DropdownMenuItem<String>(
                              value: book.id,
                              child: Text('${book.judul} (Stok: ${book.stok})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedBookId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Due Date Selector
                        Text(
                          'Batas Waktu Pengembalian',
                          style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _onPickDatePressed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.getBorder(context)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, color: AppColors.getTextPrimary(context), size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormatter.formatShort(_tanggalKembali),
                                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Icon(Icons.edit_calendar_rounded, color: AppColors.getTextSecondary(context)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        CustomButton(
                          text: 'CATAT PEMINJAMAN',
                          isLoading: loanProvider.state == ViewState.loading,
                          onPressed: _onSavePressed,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
