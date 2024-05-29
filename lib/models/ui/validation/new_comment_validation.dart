/// Represent the state of the new comment form
/// It contains the content error message (null if there is no error)
/// and a flag to indicate if the comment was posted
class NewCommentValidation {
  static const defaultValue = NewCommentValidation(
    contentError: null,
    posted: false,
  );

  final String? contentError;
  final bool posted;

  const NewCommentValidation({
    required this.contentError,
    required this.posted,
  });

  @override
  bool operator ==(Object other) {
    return other is NewCommentValidation &&
        other.contentError == contentError &&
        other.posted == posted;
  }

  @override
  int get hashCode {
    return Object.hash(contentError, posted);
  }
}
