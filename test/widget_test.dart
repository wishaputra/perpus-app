import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpus_app/main.dart';
import 'package:perpus_app/core/network/api_client.dart';
import 'package:perpus_app/domain/repositories/auth_repository.dart';
import 'package:perpus_app/domain/repositories/buku_repository.dart';
import 'package:perpus_app/domain/repositories/peminjaman_repository.dart';
import 'package:perpus_app/domain/repositories/denda_repository.dart';
import 'package:perpus_app/data/repositories/auth_repository_impl.dart';
import 'package:perpus_app/data/repositories/buku_repository_impl.dart';
import 'package:perpus_app/data/repositories/peminjaman_repository_impl.dart';
import 'package:perpus_app/data/repositories/denda_repository_impl.dart';
import 'package:perpus_app/presentation/providers/auth_provider.dart';
import 'package:perpus_app/presentation/providers/buku_provider.dart';
import 'package:perpus_app/presentation/providers/peminjaman_provider.dart';
import 'package:perpus_app/presentation/providers/denda_provider.dart';
import 'package:perpus_app/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Inisialisasi Mock SharedPreferences untuk unit test
    SharedPreferences.setMockInitialValues({});

    final apiClient = ApiClient();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          Provider<AuthRepository>(create: (_) => AuthRepositoryImpl(apiClient)),
          Provider<BukuRepository>(create: (_) => BukuRepositoryImpl(apiClient)),
          Provider<PeminjamanRepository>(create: (_) => PeminjamanRepositoryImpl(apiClient)),
          Provider<DendaRepository>(create: (_) => DendaRepositoryImpl(apiClient)),
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

    // Let any async gaps and animations complete
    await tester.pumpAndSettle();

    // Verify login screen renders elements
    expect(find.text('Perpustakaan\nDigital.'), findsOneWidget);
    expect(find.text('MASUK APLIKASI'), findsOneWidget);
  });
}
