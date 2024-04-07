import "package:proxima/models/ui/post_overview.dart";

const List<PostOverview> testPosts = [
  PostOverview(
    title: "First post",
    description: "Lorem ipsum dolor sit amet.",
    votes: 100,
    commentNumber: 5,
    posterUsername: "Proxima",
  ),
  PostOverview(
    title: "Second post",
    description:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut congue gravida justo, ut pharetra tortor sollicitudin sit amet. Etiam eu vulputate sapien.",
    votes: -10,
    commentNumber: 5,
    posterUsername: "Proxima",
  ),
  PostOverview(
    title: "Third post",
    description: "Crazy post",
    votes: 93213,
    commentNumber: 829,
    posterUsername: "Proxima",
  ),
];
