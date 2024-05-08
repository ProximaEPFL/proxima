import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/post/post_page.dart";

import "../data/post_overview.dart";
import "../overrides/override_comment_view_model.dart";
import "../overrides/override_dynamic_user_avatar_view_model.dart";

// Create a post page with the first post from the testPosts list
final postPage = MaterialApp(
  onGenerateRoute: generateRoute,
  home: PostPage(
    postOverview: testPosts.first,
  ),
);

final emptyPostPageProvider = ProviderScope(
  overrides: [
    ...mockDynamicUserAvatarViewModelTestLoginUserOverride,
    ...mockEmptyCommentViewModelOverride,
  ],
  child: postPage,
);

final nonEmptyPostPageProvider = ProviderScope(
  overrides: [
    ...mockDynamicUserAvatarViewModelTestLoginUserOverride,
    ...mockNonEmptyCommentViewModelOverride,
  ],
  child: postPage,
);
