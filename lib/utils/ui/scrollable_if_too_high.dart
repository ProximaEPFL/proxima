import "package:flutter/widgets.dart";

/// Widget that will be scrollable if its content is too high. This wraps
/// [[SingleChildScrollView]], as presented in its documentation:
/// https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
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
