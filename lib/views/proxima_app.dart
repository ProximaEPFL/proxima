import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:proxima/views/navigation/routes.dart";

class ProximaApp extends StatelessWidget {
  static const title = "Proxima";
  static const color = Color.fromARGB(255, 52, 37, 168);

  const ProximaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return MaterialApp(
      title: title,
      onGenerateRoute: generateRoute,
      initialRoute: Routes.login.name,
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: brightness,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }
}
