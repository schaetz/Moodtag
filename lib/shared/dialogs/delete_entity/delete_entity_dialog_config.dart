class DeleteEntityDialogConfig<E> {
  E? entityToDelete;
  Function() deleteHandler;
  bool resetLibrary;

  DeleteEntityDialogConfig(this.entityToDelete, this.deleteHandler, {this.resetLibrary = false});
}
