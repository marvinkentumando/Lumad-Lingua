import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
    }
    try {
      await Supabase.initialize(
        url: 'https://ovdwgowtnlujnbcyldkk.supabase.co',
        publishableKey: 'sb_publishable_rMQ9kc8SVsba4_p-aPrOPg_3XDgAbR8',
      );
    } catch (e) {
      debugPrint('Supabase initialization warning: $e');
    }
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService initialization warning: $e');
    }
    runApp(
      const ProviderScope(
        child: LumadLinguaApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught app error: $error');
  });
}

class LumadLinguaApp extends ConsumerWidget {
  const LumadLinguaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isElderMode = ref.watch(elderModeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(isElderMode ? 1.25 : 1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
