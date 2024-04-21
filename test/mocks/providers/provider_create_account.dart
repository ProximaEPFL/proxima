import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/create_account_page.dart";

import "../overrides/override_auth_providers.dart";
import "../overrides/override_firestore.dart";
import "../overrides/override_home_view_model.dart";

final ProviderScope createAccountPageProvider = ProviderScope(
  overrides: firebaseMocksOverrides +
      loggedInUserOverrides +
      mockEmptyHomeViewModelOverride,
  child: const MaterialApp(
    onGenerateRoute: generateRoute,
    title: "Create account page",
    home: CreateAccountPage(),
  ),
);
