import "package:proxima/services/database/user_repository_service.dart";

import "../../services/firestore/testing_firestore_provider.dart";

final userRepo = UserRepositoryService(
  firestore: fakeFireStore,
);

final userRepoOverride = userRepositoryProvider.overrideWithValue(userRepo);
