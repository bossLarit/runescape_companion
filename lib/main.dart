import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const minSize = Size(1024, 640);
  windowManager.waitUntilReadyToShow(
    const WindowOptions(
      minimumSize: minSize,
      size: Size(1280, 800),
      center: true,
      title: 'OSRS Companion',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWith((ref) => EnvConfigs.prod),
      ],
      child: const OSRSCompanionApp(),
    ),
  );
}
