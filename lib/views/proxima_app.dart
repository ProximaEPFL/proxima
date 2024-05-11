import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:proxima/views/navigation/routes.dart";

class ProximaApp extends StatelessWidget {
  const ProximaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return MaterialApp(
      title: "Proxima",
      onGenerateRoute: generateRoute,
      initialRoute: Routes.login.name,
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: brightness,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }
}
