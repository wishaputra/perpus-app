import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/view_state.dart';
import '../../../domain/entities/buku.dart';
import '../../providers/buku_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_card.dart';

class FormBukuScreen extends StatefulWidget {
  final Buku? book;

  const FormBukuScreen({super.key, this.book});

  @override
  State<FormBukuScreen> createState() => _FormBukuScreenState();
}

class _FormBukuScreenState extends State<FormBukuScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _judulController;
  late final TextEditingController _isbnController;
  late final TextEditingController _penulisController;
  late final TextEditingController _penerbitController;
  late final TextEditingController _jenisController;
  late final TextEditingController _tahunController;
  late final TextEditingController _stokController;
  late final TextEditingController _deskripsiController;

  bool get isEditMode => widget.book != null;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.book?.judul ?? '');
    _isbnController = TextEditingController(text: widget.book?.isbn ?? '');
    _penulisController = TextEditingController(text: widget.book?.penulis ?? '');
    _penerbitController = TextEditingController(text: widget.book?.penerbit ?? '');
    _jenisController = TextEditingController(text: widget.book?.jenis ?? '');
    _tahunController = TextEditingController(text: widget.book?.tahunTerbit.toString() ?? '');
    _stokController = TextEditingController(text: widget.book?.stok.toString() ?? '');
    _deskripsiController = TextEditingController(text: widget.book?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isbnController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _jenisController.dispose();
    _tahunController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<BukuProvider>();
      
      final bookToSubmit = Buku(
        id: widget.book?.id ?? '',
        judul: _judulController.text.trim(),
        isbn: _isbnController.text.trim(),
        penulis: _penulisController.text.trim(),
        penerbit: _penerbitController.text.trim(),
        jenis: _jenisController.text.trim(),
        tahunTerbit: int.parse(_tahunController.text),
        stok: int.parse(_stokController.text),
        deskripsi: _deskripsiController.text.trim(),
        coverUrl: widget.book?.coverUrl,
      );

      final bool success;
      if (isEditMode) {
        success = await provider.updateBook(bookToSubmit);
      } else {
        success = await provider.addBook(bookToSubmit);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Buku berhasil diperbarui!' : 'Buku baru berhasil ditambahkan!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan data buku.'),
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
    final textPrimary = AppColors.getTextPrimary(context);
    
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
                    isEditMode ? 'Ubah Data Buku' : 'Tambah Buku Baru',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form Scrollable body
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
                          'Formulir Buku',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                          controller: _judulController,
                          labelText: 'Judul Buku',
                          hintText: 'Masukkan judul buku',
                          prefixIcon: Icons.title_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'Judul harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          controller: _isbnController,
                          labelText: 'ISBN',
                          hintText: 'Masukkan nomor ISBN buku',
                          prefixIcon: Icons.tag_rounded,
                          validator: (val) => val == null || val.isEmpty ? 'ISBN harus diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _penulisController,
                                labelText: 'Penulis',
                                hintText: 'Nama penulis',
                                prefixIcon: Icons.person_rounded,
                                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _penerbitController,
                                labelText: 'Penerbit',
                                hintText: 'Nama penerbit',
                                prefixIcon: Icons.business_rounded,
                                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _jenisController,
                                labelText: 'Kategori / Jenis',
                                hintText: 'Novel, Edukasi, dll',
                                prefixIcon: Icons.category_rounded,
                                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _tahunController,
                                labelText: 'Tahun Terbit',
                                hintText: 'Contoh: 2024',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.calendar_today_rounded,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Wajib diisi';
                                  if (int.tryParse(val) == null) return 'Harus angka';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _stokController,
                                labelText: 'Jumlah Stok',
                                hintText: 'Jumlah buku',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.inventory_2_rounded,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Wajib diisi';
                                  if (int.tryParse(val) == null) return 'Harus angka';
                                  if (int.parse(val) < 0) return 'Tidak boleh negatif';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _deskripsiController,
                          labelText: 'Deskripsi / Sinopsis',
                          hintText: 'Masukkan ringkasan sinopsis buku...',
                          prefixIcon: Icons.description_rounded,
                          maxLines: 4,
                          validator: (val) => val == null || val.isEmpty ? 'Deskripsi harus diisi' : null,
                        ),
                        const SizedBox(height: 28),

                        CustomButton(
                          text: isEditMode ? 'SIMPAN PERUBAHAN' : 'TAMBAH BUKU',
                          isLoading: bookProvider.state == ViewState.loading,
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
