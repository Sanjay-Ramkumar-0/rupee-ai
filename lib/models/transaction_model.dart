import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  late String merchant;

  late String category;

  late DateTime timestamp;

  double? balance;

  String? smsBody;

  bool included = true;

  bool isIncome = false;
}
