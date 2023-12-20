enum ModalState { closed, opening, open, closing }

extension ModalStateX on ModalState {
  bool get isInTransition => this == ModalState.opening || this == ModalState.closing;
  bool get isOpeningOrOpen => this == ModalState.opening || this == ModalState.open;
}

enum OverlayVisibility { off, on, suspended }
