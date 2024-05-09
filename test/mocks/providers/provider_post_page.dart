import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/post/post_page.dart";

import "../data/post_overview.dart";
import "../overrides/override_comment_view_model.dart";
import "../overrides/override_dynamic_user_avatar_view_model.dart";
import "../overrides/override_firestore.dart";
import "../overrides/override_human_time.dart";
import "../services/mock_comment_repository_service.dart";

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

ProviderScope postPageProvider(
  MockCommentRepositoryService commentRepository,
  UserIdFirestore userId,
) {
  return ProviderScope(
    overrides: [
      ...firebaseMocksOverrides,
      ...mockEmptyCommentViewModelOverride,
      ...mockDynamicUserAvatarViewModelEmptyDisplayNameOverride,
      commentRepositoryProvider.overrideWithValue(commentRepository),
      uidProvider.overrideWithValue(userId),
    ],
    child: postPage,
  );
}

ProviderScope customPostOverviewPage(PostOverview post) {
  final customPostApp = MaterialApp(
    onGenerateRoute: generateRoute,
    home: PostPage(
      postOverview: post,
    ),
  );

  return ProviderScope(
    overrides: [
      ...mockDynamicUserAvatarViewModelTestLoginUserOverride,
      ...mockEmptyCommentViewModelOverride,
      ...humanTimeServiceOverride,
    ],
    child: customPostApp,
  );
}
