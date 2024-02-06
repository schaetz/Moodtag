class DeleteReplaceResult<O> {
  final bool confirmDeletion;
  final O? replacement;

  DeleteReplaceResult({required this.confirmDeletion, this.replacement});
}
