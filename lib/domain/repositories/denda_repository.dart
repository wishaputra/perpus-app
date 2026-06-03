import '../entities/denda.dart';

abstract class DendaRepository {
  Future<List<Denda>> getAllDenda();
  Future<Denda> bayarDenda(String id);
}
