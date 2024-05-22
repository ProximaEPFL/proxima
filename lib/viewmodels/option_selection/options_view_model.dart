import "package:hooks_riverpod/hooks_riverpod.dart";

/// Abstract view model for the option selection
abstract class OptionsViewModel<T> extends Notifier<T> {
  final T defaultOption;

  OptionsViewModel(this.defaultOption);

  @override
  T build() {
    return defaultOption;
  }

  void setOption(T option) {
    state = option;
  }
}
