import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/firebase_options.dart";
import "package:proxima/views/proxima_app.dart";

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the splash screen for initialization
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide splash screen
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: ProximaApp(),
    ),
  );
}
