class DeleteWithReplacementResult<O> {
  final bool confirmDeletion;
  final O? replacement;

  DeleteWithReplacementResult({required this.confirmDeletion, this.replacement});
}
