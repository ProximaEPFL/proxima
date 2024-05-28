import "package:flutter/cupertino.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/option_selection/options_view_model.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";

class SelectedPageViewModel extends OptionsViewModel<NavigationBarRoutes> {
  static const defaultSelectedPage = NavigationBarRoutes.feed;

  SelectedPageViewModel() : super(defaultSelectedPage);

  @override
  void setOption(NavigationBarRoutes option) {
    if (option.routeDestination != null) {
      throw Exception(
          "This page should be pushed and not set as the selected page."
          "Use the navigate method instead.");
    }
    super.setOption(option);
  }

  void navigate(NavigationBarRoutes route, BuildContext context) {
    if (route.routeDestination == null) {
      setOption(route);
    } else {
      Navigator.pushNamed(context, route.routeDestination!.name);
    }
  }
}

final selectedPageViewModelProvider =
    NotifierProvider<SelectedPageViewModel, NavigationBarRoutes>(
  () => SelectedPageViewModel(),
);
