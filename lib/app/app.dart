import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/config/environment.dart';
import 'router.dart';
import 'theme.dart';

class OSRSCompanionApp extends HookConsumerWidget {
  const OSRSCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final env = ref.watch(envConfigProvider);

    return MaterialApp.router(
      title: env.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: env.showDebugBanner,
      routerConfig: router,
    );
  }
}
