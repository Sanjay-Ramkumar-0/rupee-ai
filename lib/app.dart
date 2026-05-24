import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/finance_notifier.dart';
import 'screens/onboarding/setup_screen.dart';
import 'screens/shell/main_shell.dart';
import 'services/payment_notification_service.dart';

class RupeeApp extends ConsumerStatefulWidget {
  const RupeeApp({super.key});

  @override
  ConsumerState<RupeeApp> createState() => _RupeeAppState();
}

class _RupeeAppState extends ConsumerState<RupeeApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(paymentNotificationServiceProvider).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(financeProvider).profile;

    return MaterialApp(
      title: 'Rupee AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: profile.setupComplete ? const MainShell() : const SetupScreen(),
    );
  }
}
