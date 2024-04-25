import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

typedef FutureVoidCallback = Future<void> Function();

enum DeletionState {
  existing,
  pending,
  deleted,
}

class DeleteButton extends HookConsumerWidget {
  static const _deleteIconSize = 26.0;
  static const _containerSide = 35.0;

  final FutureVoidCallback onClick;
  final double iconSize;

  const DeleteButton({
    super.key,
    required this.onClick,
    this.iconSize = _deleteIconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(DeletionState.existing);

    final deleteButton = IconButton(
      icon: Icon(Icons.delete, size: iconSize),
      onPressed: () async {
        isLoading.value = DeletionState.pending;
        await onClick();
        isLoading.value = DeletionState.deleted;
      },
    );

    final loading = Center(
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: const CircularProgressIndicator(),
      ),
    );

    final checkButton = IconButton(
      icon: Icon(Icons.check, size: iconSize),
      onPressed: null,
    );

    return SizedBox(
      width: _containerSide,
      height: _containerSide,
      child: switch (isLoading.value) {
        DeletionState.existing => deleteButton,
        DeletionState.pending => loading,
        DeletionState.deleted => checkButton,
      },
    );
  }
}
