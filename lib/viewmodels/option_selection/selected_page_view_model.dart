import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/selected_page_details.dart";
import "package:proxima/viewmodels/option_selection/options_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

class SelectedPageViewModel extends OptionsViewModel<SelectedPageDetails> {
  static const defaultSelectedPage =
      SelectedPageDetails(route: NavigationBarRoutes.feed);

  SelectedPageViewModel() : super(defaultSelectedPage);

  @override
  void setOption(SelectedPageDetails option) {
    if (option.route.routeDestination != null) {
      throw Exception(
          "This page should be pushed and not set as the selected page."
          "push it manually from your context instead.");
    }
    super.setOption(option);
  }

  void selectPage(NavigationBarRoutes route, [Object? args]) {
    setOption(SelectedPageDetails(route: route, args: args));
  }
}

final selectedPageViewModelProvider =
    NotifierProvider<SelectedPageViewModel, SelectedPageDetails>(
  () => SelectedPageViewModel(),
);
