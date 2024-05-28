import "package:flutter/material.dart";

class MapAction extends StatelessWidget {
  final int depth;

  const MapAction({super.key, required this.depth});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        for (var i = 0; i < depth; i++) {
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.map),
    );
  }
}
