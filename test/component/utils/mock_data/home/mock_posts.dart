import "package:proxima/models/ui/post_overview.dart";

const List<PostOverview> testPosts = [
  PostOverview(
    title: "First post",
    description: "Lorem ipsum dolor sit amet.",
    voteScore: 100,
    commentNumber: 5,
    ownerDisplayName: "Proxima",
  ),
  PostOverview(
    title: "Second post",
    description:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut congue gravida justo, ut pharetra tortor sollicitudin sit amet. Etiam eu vulputate sapien.",
    voteScore: -10,
    commentNumber: 5,
    ownerDisplayName: "Proxima",
  ),
  PostOverview(
    title: "Third post",
    description: "Crazy post",
    voteScore: 93213,
    commentNumber: 829,
    ownerDisplayName: "Proxima",
  ),
];
