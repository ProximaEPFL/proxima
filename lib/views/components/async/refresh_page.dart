import "package:flutter/material.dart";

class RefreshPage extends StatelessWidget {
  final void Function() onRefresh;

  static const refreshButtonKey = Key("refreshButton");

  const RefreshPage({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final refreshButton = ElevatedButton(
      key: refreshButtonKey,
      onPressed: onRefresh,
      child: const Text("Refresh"),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("An error occurred"),
          const SizedBox(height: 10),
          refreshButton,
        ],
      ),
    );
  }
}
