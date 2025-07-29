enum PieceType { red, black }
enum PieceState { normal, king }

class CheckerPiece {
  final PieceType type;
  PieceState state;
  final int row;
  final int col;

  CheckerPiece({
    required this.type,
    this.state = PieceState.normal,
    required this.row,
    required this.col,
  });

  bool get isKing => state == PieceState.king;
  bool get isRed => type == PieceType.red;
  bool get isBlack => type == PieceType.black;

  void promoteToKing() {
    if (state == PieceState.normal) {
      state = PieceState.king;
    }
  }

  CheckerPiece copyWith({
    PieceType? type,
    PieceState? state,
    int? row,
    int? col,
  }) {
    return CheckerPiece(
      type: type ?? this.type,
      state: state ?? this.state,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckerPiece &&
        other.type == type &&
        other.state == state &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode {
    return Object.hash(type, state, row, col);
  }
} 