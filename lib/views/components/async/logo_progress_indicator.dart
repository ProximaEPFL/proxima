import "package:flutter/material.dart";

/// A progress indicator that displays the animated Proxima logo.
/// Used to indicate that the app is loading data. And provide an
/// alternative to the default circular progress indicator.
class LogoProgressIndicator extends StatelessWidget {
  const LogoProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/feedback/proxima_progress_indicator_transparent.gif",
      width: 75,
    );
  }
}
