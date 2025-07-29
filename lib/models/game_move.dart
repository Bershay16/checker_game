import 'checker_piece.dart';

class GameMove {
  final CheckerPiece piece;
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final List<CheckerPiece> capturedPieces;
  final bool isJump;

  GameMove({
    required this.piece,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.capturedPieces = const [],
    this.isJump = false,
  });

  bool get isPromotion {
    return (piece.isRed && toRow == 0) || (piece.isBlack && toRow == 7);
  }

  GameMove copyWith({
    CheckerPiece? piece,
    int? fromRow,
    int? fromCol,
    int? toRow,
    int? toCol,
    List<CheckerPiece>? capturedPieces,
    bool? isJump,
  }) {
    return GameMove(
      piece: piece ?? this.piece,
      fromRow: fromRow ?? this.fromRow,
      fromCol: fromCol ?? this.fromCol,
      toRow: toRow ?? this.toRow,
      toCol: toCol ?? this.toCol,
      capturedPieces: capturedPieces ?? this.capturedPieces,
      isJump: isJump ?? this.isJump,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameMove &&
        other.piece == piece &&
        other.fromRow == fromRow &&
        other.fromCol == fromCol &&
        other.toRow == toRow &&
        other.toCol == toCol;
  }

  @override
  int get hashCode {
    return Object.hash(piece, fromRow, fromCol, toRow, toCol);
  }
} 