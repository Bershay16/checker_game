import 'checker_piece.dart';
import 'game_move.dart';

enum GameStatus { playing, redWon, blackWon, draw }

class GameState {
  final List<List<CheckerPiece?>> board;
  final PieceType currentPlayer;
  final GameStatus status;
  final CheckerPiece? selectedPiece;
  final List<GameMove> validMoves;
  final List<GameMove> moveHistory;

  GameState({
    required this.board,
    this.currentPlayer = PieceType.red,
    this.status = GameStatus.playing,
    this.selectedPiece,
    this.validMoves = const [],
    this.moveHistory = const [],
  });

  bool get isGameOver => status != GameStatus.playing;
  bool get isRedTurn => currentPlayer == PieceType.red;
  bool get isBlackTurn => currentPlayer == PieceType.black;

  CheckerPiece? getPiece(int row, int col) {
    if (row < 0 || row >= 8 || col < 0 || col >= 8) return null;
    return board[row][col];
  }

  GameState copyWith({
    List<List<CheckerPiece?>>? board,
    PieceType? currentPlayer,
    GameStatus? status,
    CheckerPiece? selectedPiece,
    List<GameMove>? validMoves,
    List<GameMove>? moveHistory,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      selectedPiece: selectedPiece ?? this.selectedPiece,
      validMoves: validMoves ?? this.validMoves,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  GameState withNewBoard(List<List<CheckerPiece?>> newBoard) {
    return copyWith(board: newBoard);
  }

  GameState withNewMove(GameMove move) {
    final newMoveHistory = List<GameMove>.from(moveHistory)..add(move);
    return copyWith(moveHistory: newMoveHistory);
  }
} 