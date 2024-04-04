import "package:flutter/material.dart";

class LeadingBackButton extends StatelessWidget {
  static const leadingBackButtonKey = Key("leadingBackButtonKey");
  const LeadingBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: leadingBackButtonKey,
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}
