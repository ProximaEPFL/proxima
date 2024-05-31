import "package:flutter/material.dart";

class LeadingBackButton extends StatelessWidget {
  static const leadingBackButtonKey = Key("leadingBackButtonKey");

  final VoidCallback? onPressed;

  const LeadingBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final backButton = IconButton(
      key: leadingBackButtonKey,
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: backButton,
    );
  }
}
