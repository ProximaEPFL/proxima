import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "../overrides/mock_home_view_model.dart";

const homePageApp = MaterialApp(
  onGenerateRoute: generateRoute,
  home: HomePage(),
);

final mockedEmptyHomePage = ProviderScope(
  overrides: mockEmptyHomeViewModelOverride,
  child: homePageApp,
);

final mockedNonEmptyHomePage = ProviderScope(
  overrides: mockNonEmptyHomeViewModelOverride,
  child: homePageApp,
);

final mockedLoadingHomePage = ProviderScope(
  overrides: mockLoadingHomeViewModelOverride,
  child: homePageApp,
);
