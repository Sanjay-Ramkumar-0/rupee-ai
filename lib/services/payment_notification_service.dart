import 'dart:io';

import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/transaction.dart';
import '../providers/finance_notifier.dart';
import 'notification_payment_parser.dart';

/// Listens to Android payment-app notifications and records transactions.
class PaymentNotificationService {
  PaymentNotificationService(this._ref);

  final Ref _ref;
  bool _initialized = false;

  Future<void> init() async {
    if (!Platform.isAndroid || _initialized) return;
    _initialized = true;
    await NotificationsListener.initialize();
    NotificationsListener.receivePort?.listen(_onNotification);
  }

  Future<bool> get hasPermission async {
    if (!Platform.isAndroid) return false;
    return (await NotificationsListener.hasPermission) == true;
  }

  Future<void> openPermissionSettings() async {
    if (!Platform.isAndroid) return;
    await NotificationsListener.openPermissionSettings();
  }

  Future<bool> startListening() async {
    if (!Platform.isAndroid) return false;
    final permitted = await hasPermission;
    if (!permitted) return false;
    final running = (await NotificationsListener.isRunning) == true;
    if (!running) {
      await NotificationsListener.startService(
        foreground: true,
        title: 'Rupee AI',
        description: 'Reading payment notifications to track spending',
      );
    }
    return true;
  }

  void _onNotification(dynamic event) {
    if (event is! NotificationEvent) return;

    final pkg = event.packageName ?? '';
    if (!NotificationPaymentParser.isPaymentApp(pkg)) return;

    final parsed = NotificationPaymentParser.parse(
      title: event.title ?? '',
      text: event.text ?? '',
      packageName: pkg,
    );
    if (parsed == null) return;

    final txn = Transaction(
      id: 'notif_${event.uniqueId ?? DateTime.now().millisecondsSinceEpoch}',
      amount: parsed.amount,
      merchant: parsed.merchant,
      category: parsed.isIncome
          ? receivedCategory
          : '',
      timestamp: DateTime.now(),
      paymentType: 'UPI',
      isIncome: parsed.isIncome,
      included: true,
      notes: parsed.rawText,
      source: 'notification',
    );

    _ref.read(financeProvider.notifier).handleNotificationTransaction(txn);
  }
}

final paymentNotificationServiceProvider = Provider<PaymentNotificationService>(
  (ref) => PaymentNotificationService(ref),
);
