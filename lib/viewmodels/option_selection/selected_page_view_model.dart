import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/home_page_options.dart";
import "package:proxima/viewmodels/option_selection/options_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

class SelectedPageViewModel extends OptionsViewModel<HomePageOptions> {
  static const defaultSelectedPage =
      HomePageOptions(route: NavigationBarRoutes.feed);

  SelectedPageViewModel() : super(defaultSelectedPage);

  @override
  void setOption(HomePageOptions option) {
    if (option.route.routeDestination != null) {
      throw Exception(
          "This page should be pushed and not set as the selected page."
          "Use the navigate method instead.");
    }
    super.setOption(option);
  }

  void navigate(NavigationBarRoutes route, [Object? args]) {
    setOption(HomePageOptions(route: route, args: args));
  }
}

final selectedPageViewModelProvider =
    NotifierProvider<SelectedPageViewModel, HomePageOptions>(
  () => SelectedPageViewModel(),
);
