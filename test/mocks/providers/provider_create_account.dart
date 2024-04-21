import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/create_account_page.dart";

import "../../services/firestore/testing_firestore_provider.dart";
import "../overrides/mock_auth_providers.dart";
import "../overrides/mock_home_view_model.dart";

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
