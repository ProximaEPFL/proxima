import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/post_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/post/post_page.dart";

import "../data/post_comment.dart";
import "../data/post_overview.dart";
import "../overrides/override_dynamic_user_avatar_view_model.dart";

// Create a post page with the first post from the testPosts list
final postPage = MaterialApp(
  onGenerateRoute: generateRoute,
  home: PostPage(
    postOverview: testPosts.first,
  ),
);

final emptyPostPageProvider = ProviderScope(
  overrides: [...mockDynamicUserAvatarViewModelTestLoginUserOverride],
  child: postPage,
);

final nonEmptyPostPageProvider = ProviderScope(
  overrides: [
    ...mockDynamicUserAvatarViewModelTestLoginUserOverride,
    commentListProvider.overrideWithValue(testComments),
  ],
  child: postPage,
);
