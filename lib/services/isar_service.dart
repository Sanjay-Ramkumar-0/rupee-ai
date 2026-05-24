import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/transaction_model.dart';

class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();

  Isar? _isar;

  bool get isInitialized => _isar != null;

  Isar get isar {
    final database = _isar;
    if (database == null) {
      throw StateError('Isar is not initialized. Call init() in main() first.');
    }
    return database;
  }

  /// Opens Isar. Pass [directory] in tests (path_provider is unavailable there).
  Future<void> init({String? directory}) async {
    if (_isar != null) return;

    final dirPath = directory ?? (await getApplicationDocumentsDirectory()).path;
    _isar = await Isar.open(
      [TransactionModelSchema],
      directory: dirPath,
    );
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Inserts or updates a transaction (Isar `put`).
  Future<int> saveTransaction(TransactionModel transaction) async {
    return isar.writeTxn(() => isar.transactionModels.put(transaction));
  }

  Future<List<TransactionModel>> getTransactions() async {
    return isar.transactionModels.where().sortByTimestampDesc().findAll();
  }

  Future<bool> deleteTransaction(int id) async {
    return isar.writeTxn(() => isar.transactionModels.delete(id));
  }

  Future<int> deleteTransactions(List<int> ids) async {
    if (ids.isEmpty) return 0;
    return isar.writeTxn(() => isar.transactionModels.deleteAll(ids));
  }

  Future<void> deleteAllTransactions() async {
    await isar.writeTxn(() => isar.transactionModels.clear());
  }
}
