import '../core/constants/categories.dart';

class ParsedPaymentNotification {
  const ParsedPaymentNotification({
    required this.amount,
    required this.merchant,
    required this.isIncome,
    required this.rawText,
  });

  final double amount;
  final String merchant;
  final bool isIncome;
  final String rawText;
}

/// Parses UPI / bank notification text from payment apps.
abstract final class NotificationPaymentParser {
  static final _amountPattern = RegExp(
    r'(?:₹|rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final _incomeKeywords = RegExp(
    r'\b(received|credited|credit|deposited|sent you|money received)\b',
    caseSensitive: false,
  );

  static final _expenseKeywords = RegExp(
    r'\b(debited|debit|spent|paid|sent to|payment made|purchase)\b',
    caseSensitive: false,
  );

  static ParsedPaymentNotification? parse({
    required String title,
    required String text,
    String? packageName,
  }) {
    final combined = '$title $text'.trim();
    if (combined.isEmpty) return null;

    final amount = _extractAmount(combined);
    if (amount == null || amount <= 0) return null;

    final isIncome = _detectIncome(combined);
    if (!isIncome && !_expenseKeywords.hasMatch(combined)) {
      // Skip non-payment notifications unless clearly payment-related
      if (!_looksLikePayment(combined)) return null;
    }

    final merchant = _extractMerchant(title, text, combined);

    return ParsedPaymentNotification(
      amount: amount,
      merchant: merchant,
      isIncome: isIncome,
      rawText: combined,
    );
  }

  static bool isPaymentApp(String? packageName) {
    if (packageName == null || packageName.isEmpty) return false;
    if (paymentAppPackages.contains(packageName)) return true;
    return packageName.contains('pay') ||
        packageName.contains('bank') ||
        packageName.contains('upi') ||
        packageName.contains('paisa');
  }

  static double? _extractAmount(String text) {
    final match = _amountPattern.firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '');
    return double.tryParse(raw);
  }

  static bool _detectIncome(String text) {
    if (_incomeKeywords.hasMatch(text)) return true;
    if (_expenseKeywords.hasMatch(text)) return false;
    return text.toLowerCase().contains('received');
  }

  static bool _looksLikePayment(String text) {
    return _amountPattern.hasMatch(text) &&
        (text.toLowerCase().contains('upi') ||
            text.toLowerCase().contains('txn') ||
            text.toLowerCase().contains('transaction') ||
            text.toLowerCase().contains('a/c'));
  }

  static String _extractMerchant(String title, String text, String combined) {
    final from = RegExp(
      r'(?:to|at|from|paid to|received from|sent to)\s+([A-Za-z0-9 .&\-]{2,40})',
      caseSensitive: false,
    ).firstMatch(combined);
    if (from != null) {
      return from.group(1)!.trim();
    }
    if (title.isNotEmpty && title.length < 50) return title.trim();
    final firstLine = text.split('\n').first.trim();
    if (firstLine.isNotEmpty && firstLine.length < 50) return firstLine;
    return 'Payment';
  }

  static String defaultCategory(bool isIncome) =>
      isIncome ? receivedCategory : '';
}
