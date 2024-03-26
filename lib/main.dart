import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/firebase/firebase_options.dart";
import "package:proxima/views/navigation/routes.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: ProximaApp(),
    ),
  );
}

class ProximaApp extends StatelessWidget {
  const ProximaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Proxima",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.light,
        ),
      ),
      onGenerateRoute: generateRoute,
      //TODO CHANGE BACK TO LOGIN
      initialRoute: Routes.profile.name,
    );
  }
}
