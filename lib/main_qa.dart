import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app.dart';
import 'core/config/environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWith((ref) => EnvConfigs.qa),
      ],
      child: const OSRSCompanionApp(),
    ),
  );
}
