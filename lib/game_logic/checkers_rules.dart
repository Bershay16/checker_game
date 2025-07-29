import '../models/checker_piece.dart';
import '../models/game_move.dart';
import '../models/game_state.dart';

class CheckersRules {
  static const int boardSize = 8;

  static List<List<CheckerPiece?>> createInitialBoard() {
    final board = List<List<CheckerPiece?>>.generate(
      boardSize,
      (row) => List<CheckerPiece?>.generate(boardSize, (col) => null),
    );

    // Place black pieces (top)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < boardSize; col++) {
        if ((row + col) % 2 == 1) {
          board[row][col] = CheckerPiece(
            type: PieceType.black,
            row: row,
            col: col,
          );
        }
      }
    }

    // Place red pieces (bottom)
    for (int row = 5; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if ((row + col) % 2 == 1) {
          board[row][col] = CheckerPiece(
            type: PieceType.red,
            row: row,
            col: col,
          );
        }
      }
    }

    return board;
  }

  static List<GameMove> getValidMoves(GameState state, CheckerPiece piece) {
    final moves = <GameMove>[];

    // Check for jumps first
    final jumpMoves = getJumpMoves(state, piece);
    if (jumpMoves.isNotEmpty) {
      return jumpMoves;
    }

    // If no jumps, check regular moves
    final directions = piece.isKing ? [-1, 1] : (piece.isRed ? [-1] : [1]);
    final cols = [-1, 1];

    for (final rowDir in directions) {
      for (final colDir in cols) {
        final newRow = piece.row + rowDir;
        final newCol = piece.col + colDir;

        if (_isValidPosition(newRow, newCol) &&
            state.getPiece(newRow, newCol) == null) {
          moves.add(
            GameMove(
              piece: piece,
              fromRow: piece.row,
              fromCol: piece.col,
              toRow: newRow,
              toCol: newCol,
            ),
          );
        }
      }
    }

    return moves;
  }

  static List<GameMove> getJumpMoves(GameState state, CheckerPiece piece) {
    final jumps = <GameMove>[];
    final directions = piece.isKing ? [-1, 1] : (piece.isRed ? [-1] : [1]);
    final cols = [-1, 1];

    for (final rowDir in directions) {
      for (final colDir in cols) {
        final jumpRow = piece.row + (rowDir * 2);
        final jumpCol = piece.col + (colDir * 2);
        final middleRow = piece.row + rowDir;
        final middleCol = piece.col + colDir;

        if (_isValidPosition(jumpRow, jumpCol) &&
            _isValidPosition(middleRow, middleCol)) {
          final middlePiece = state.getPiece(middleRow, middleCol);
          final jumpPiece = state.getPiece(jumpRow, jumpCol);

          if (middlePiece != null &&
              middlePiece.type != piece.type &&
              jumpPiece == null) {
            jumps.add(
              GameMove(
                piece: piece,
                fromRow: piece.row,
                fromCol: piece.col,
                toRow: jumpRow,
                toCol: jumpCol,
                capturedPieces: [middlePiece],
                isJump: true,
              ),
            );
          }
        }
      }
    }

    return jumps;
  }

  static bool _isValidPosition(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  static GameState applyMove(GameState state, GameMove move) {
    final newBoard = List<List<CheckerPiece?>>.generate(
      boardSize,
      (row) => List<CheckerPiece?>.generate(
        boardSize,
        (col) => state.board[row][col],
      ),
    );

    // Remove the piece from its original position
    newBoard[move.fromRow][move.fromCol] = null;

    // Create the moved piece
    final movedPiece = CheckerPiece(
      type: move.piece.type,
      state: move.piece.state,
      row: move.toRow,
      col: move.toCol,
    );

    // Promote to king if reaching the opposite end
    if (move.isPromotion) {
      movedPiece.promoteToKing();
    }

    newBoard[move.toRow][move.toCol] = movedPiece;

    // Remove captured pieces
    for (final captured in move.capturedPieces) {
      newBoard[captured.row][captured.col] = null;
    }

    // Check for additional jumps only if this was a jump move
    List<GameMove> additionalJumps = [];
    PieceType nextPlayer;
    
    if (move.isJump) {
      // If this was a jump, check for additional jumps
      additionalJumps = getJumpMoves(
        state.copyWith(board: newBoard),
        movedPiece,
      );
      
      // Switch player if no additional jumps
      nextPlayer = additionalJumps.isEmpty
          ? (state.currentPlayer == PieceType.red
                ? PieceType.black
                : PieceType.red)
          : state.currentPlayer;
    } else {
      // If this was a regular move, always switch to the other player
      nextPlayer = state.currentPlayer == PieceType.red
          ? PieceType.black
          : PieceType.red;
    }

    // Check game status
    final gameStatus = _checkGameStatus(newBoard, nextPlayer);

    return state.copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
      status: gameStatus,
      selectedPiece: null,
      validMoves: additionalJumps,
    );
  }

  static GameStatus _checkGameStatus(
    List<List<CheckerPiece?>> board,
    PieceType currentPlayer,
  ) {
    int redPieces = 0;
    int blackPieces = 0;
    bool redCanMove = false;
    bool blackCanMove = false;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final piece = board[row][col];
        if (piece != null) {
          if (piece.isRed) {
            redPieces++;
            if (!redCanMove) {
              redCanMove = _hasValidMoves(board, piece);
            }
          } else {
            blackPieces++;
            if (!blackCanMove) {
              blackCanMove = _hasValidMoves(board, piece);
            }
          }
        }
      }
    }

    if (redPieces == 0) return GameStatus.blackWon;
    if (blackPieces == 0) return GameStatus.redWon;
    if (!redCanMove && currentPlayer == PieceType.red) {
      return GameStatus.blackWon;
    }
    if (!blackCanMove && currentPlayer == PieceType.black) {
      return GameStatus.redWon;
    }
    if (!redCanMove && !blackCanMove) return GameStatus.draw;

    return GameStatus.playing;
  }

  static bool _hasValidMoves(
    List<List<CheckerPiece?>> board,
    CheckerPiece piece,
  ) {
    // Check for jumps first
    final jumpMoves = _getJumpMovesForPiece(board, piece);
    if (jumpMoves.isNotEmpty) return true;

    // Check for regular moves
    final directions = piece.isKing ? [-1, 1] : (piece.isRed ? [-1] : [1]);
    final cols = [-1, 1];

    for (final rowDir in directions) {
      for (final colDir in cols) {
        final newRow = piece.row + rowDir;
        final newCol = piece.col + colDir;

        if (_isValidPosition(newRow, newCol) && board[newRow][newCol] == null) {
          return true;
        }
      }
    }

    return false;
  }

  static List<GameMove> _getJumpMovesForPiece(
    List<List<CheckerPiece?>> board,
    CheckerPiece piece,
  ) {
    final jumps = <GameMove>[];
    final directions = piece.isKing ? [-1, 1] : (piece.isRed ? [-1] : [1]);
    final cols = [-1, 1];

    for (final rowDir in directions) {
      for (final colDir in cols) {
        final jumpRow = piece.row + (rowDir * 2);
        final jumpCol = piece.col + (colDir * 2);
        final middleRow = piece.row + rowDir;
        final middleCol = piece.col + colDir;

        if (_isValidPosition(jumpRow, jumpCol) &&
            _isValidPosition(middleRow, middleCol)) {
          final middlePiece = board[middleRow][middleCol];
          final jumpPiece = board[jumpRow][jumpCol];

          if (middlePiece != null &&
              middlePiece.type != piece.type &&
              jumpPiece == null) {
            jumps.add(
              GameMove(
                piece: piece,
                fromRow: piece.row,
                fromCol: piece.col,
                toRow: jumpRow,
                toCol: jumpCol,
                capturedPieces: [middlePiece],
                isJump: true,
              ),
            );
          }
        }
      }
    }

    return jumps;
  }
}
