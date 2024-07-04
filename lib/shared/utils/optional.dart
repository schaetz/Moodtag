class Optional<T> {
  final bool _present;
  final T? _content;

  bool get isPresent => _present;
  T? get content => _present ? _content : null;

  Optional(this._content) : this._present = true;
  Optional.none()
      : this._present = false,
        this._content = null;
}
