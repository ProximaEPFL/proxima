import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

typedef FutureVoidCallback = Future<void> Function();

class DeleteButton extends HookConsumerWidget {
  static const _deleteIconSize = 32.0;

  final FutureVoidCallback onClick;
  final double iconSize;

  const DeleteButton({
    super.key,
    required this.onClick,
    this.iconSize = _deleteIconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    if (isLoading.value) {
      return const CircularProgressIndicator();
    }

    return IconButton(
      icon: Icon(Icons.delete, size: iconSize),
      onPressed: () async {
        isLoading.value = true;
        await onClick();

        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
