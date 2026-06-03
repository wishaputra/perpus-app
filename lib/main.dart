import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/utils/view_state.dart';

// Data repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/buku_repository_impl.dart';
import 'data/repositories/peminjaman_repository_impl.dart';
import 'data/repositories/denda_repository_impl.dart';

// Domain repositories
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/buku_repository.dart';
import 'domain/repositories/peminjaman_repository.dart';
import 'domain/repositories/denda_repository.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/buku_provider.dart';
import 'presentation/providers/peminjaman_provider.dart';
import 'presentation/providers/denda_provider.dart';
import 'presentation/providers/theme_provider.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi lokalisasi tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Instansiasi klien API pusat
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        // Theme Provider diletakkan di paling atas agar dapat dibaca oleh widget di bawahnya
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        
        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl(apiClient)),
        Provider<BukuRepository>(create: (_) => BukuRepositoryImpl(apiClient)),
        Provider<PeminjamanRepository>(create: (_) => PeminjamanRepositoryImpl(apiClient)),
        Provider<DendaRepository>(create: (_) => DendaRepositoryImpl(apiClient)),
        
        // State Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<BukuProvider>(
          create: (context) => BukuProvider(context.read<BukuRepository>()),
        ),
        ChangeNotifierProvider<PeminjamanProvider>(
          create: (context) => PeminjamanProvider(context.read<PeminjamanRepository>()),
        ),
        ChangeNotifierProvider<DendaProvider>(
          create: (context) => DendaProvider(context.read<DendaRepository>()),
        ),
      ],
      child: const PerpusApp(),
    ),
  );
}

class PerpusApp extends StatefulWidget {
  const PerpusApp({super.key});

  @override
  State<PerpusApp> createState() => _PerpusAppState();
}

class _PerpusAppState extends State<PerpusApp> {
  @override
  void initState() {
    super.initState();
    // Periksa apakah token login sudah tersimpan saat aplikasi dijalankan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Perpustakaan Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Tampilkan loading saat memvalidasi sesi lama
          if (auth.state == ViewState.loading && auth.user == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryLight),
              ),
            );
          }
          
          if (auth.isAuthenticated) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
