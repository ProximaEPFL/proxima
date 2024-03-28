import "package:flutter/widgets.dart";

class ScrollableIfTooHigh extends StatelessWidget {
  final Widget child;

  const ScrollableIfTooHigh({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
