import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/options_view_model.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";

/// View model for the map selection options. It keeps in memory
/// which chip is selected.
class MapSelectionOptionsViewModel
    extends OptionsViewModel<MapSelectionOptions> {
  static const defaultMapOption = MapSelectionOptions.nearby;

  MapSelectionOptionsViewModel() : super(defaultMapOption);
}

final mapSelectionOptionsViewModelProvider =
    NotifierProvider<MapSelectionOptionsViewModel, MapSelectionOptions>(
  () => MapSelectionOptionsViewModel(),
);
