import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/authentication/auth_login_service.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

import "../overrides/override_auth_providers.dart";
import "../overrides/override_posts_feed_view_model.dart";

const profilePageApp = MaterialApp(
  onGenerateRoute: generateRoute,
  title: "Profile page",
  home: ProfilePage(),
);

ProviderScope profileProviderScope(
  FakeFirebaseFirestore fakeFireStore,
  Widget child,
) {
  final userRepo = UserRepositoryService(
    firestore: fakeFireStore,
  );
  final postRepo = PostRepositoryService(
    firestore: fakeFireStore,
  );

  final userCommentRepo = UserCommentReposittoryService(
    firestore: fakeFireStore,
  );

  final commentRepo = CommentRepositoryService(
    firestore: fakeFireStore,
  );

  return ProviderScope(
    overrides: [
      ...mockEmptyHomeViewModelOverride,
      firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
      userRepositoryServiceProvider.overrideWithValue(userRepo),
      postRepositoryServiceProvider.overrideWithValue(postRepo),
      userCommentRepositoryServiceProvider.overrideWithValue(userCommentRepo),
      commentRepositoryServiceProvider.overrideWithValue(commentRepo),
    ],
    child: child,
  );
}
