class NewPostValidation {
  final String? titleError;
  final String? descriptionError;
  final bool posted;

  NewPostValidation({
    required this.titleError,
    required this.descriptionError,
    required this.posted,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewPostValidation &&
        other.titleError == titleError &&
        other.descriptionError == descriptionError &&
        other.posted == posted;
  }

  @override
  int get hashCode {
    return Object.hash(titleError, descriptionError, posted);
  }
}
