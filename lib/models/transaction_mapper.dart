import 'transaction.dart';
import 'transaction_model.dart';

/// Maps between Isar [TransactionModel] and UI [Transaction].
abstract final class TransactionMapper {
  static Transaction toDomain(TransactionModel model) {
    return Transaction(
      id: model.id.toString(),
      amount: model.amount,
      merchant: model.merchant,
      category: model.category,
      timestamp: model.timestamp,
      paymentType: _paymentTypeFrom(model),
      included: model.included,
      isIncome: model.isIncome,
      notes: model.smsBody,
      source: model.isIncome ? 'notification' : null,
    );
  }

  static List<Transaction> toDomainList(List<TransactionModel> models) {
    return models.map(toDomain).toList();
  }

  static TransactionModel toModel(Transaction transaction) {
    final model = TransactionModel()
      ..amount = transaction.amount
      ..merchant = transaction.merchant
      ..category = transaction.category
      ..timestamp = transaction.timestamp
      ..balance = null
      ..smsBody = transaction.notes
      ..included = transaction.included
      ..isIncome = transaction.isIncome;
    final isarId = int.tryParse(transaction.id);
    if (isarId != null) model.id = isarId;
    return model;
  }

  static String _paymentTypeFrom(TransactionModel model) {
    if (model.merchant == 'Cash expense') return 'Cash';
    if (model.isIncome) return 'Received';
    return 'UPI';
  }
}
