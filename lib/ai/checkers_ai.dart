import '../models/game_move.dart';
import '../models/game_state.dart';
import '../models/checker_piece.dart';
import '../game_logic/checkers_rules.dart';

class CheckersAI {
  static const int maxDepth = 5; 

  static GameMove getBestMove(GameState state) {
    final moves = <GameMove>[];

    // Collect all valid moves for AI pieces (black pieces)
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.getPiece(row, col);
        if (piece != null && piece.type == PieceType.black) {
          moves.addAll(CheckersRules.getValidMoves(state, piece));
        }
      }
    }

    if (moves.isEmpty) {
      return GameMove(
        piece: CheckerPiece(type: PieceType.black, row: 0, col: 0),
        fromRow: 0,
        fromCol: 0,
        toRow: 0,
        toCol: 0,
      );
    }

    // Prioritize capturing moves
    final capturingMoves = moves.where((move) => move.isJump).toList();
    final nonCapturingMoves = moves.where((move) => !move.isJump).toList();

    // If there are capturing moves available, find the best chain
    if (capturingMoves.isNotEmpty) {
      return _findBestCaptureChain(state, capturingMoves);
    }

    // If no capturing moves, evaluate regular moves
    GameMove? bestMove;
    double bestScore = double.negativeInfinity;

    for (final move in nonCapturingMoves) {
      final newState = CheckersRules.applyMove(state, move);
      final score = _minimax(
        newState,
        maxDepth - 1,
        double.negativeInfinity,
        double.infinity,
        false,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? nonCapturingMoves.first;
  }

  static GameMove _findBestCaptureChain(GameState state, List<GameMove> initialMoves) {
    GameMove? bestMove;
    double bestScore = double.negativeInfinity;

    for (final initialMove in initialMoves) {
      final score = _evaluateCaptureChain(state, initialMove);
      if (score > bestScore) {
        bestScore = score;
        bestMove = initialMove;
      }
    }

    return bestMove ?? initialMoves.first;
  }

  static double _evaluateCaptureChain(GameState state, GameMove initialMove) {
    double totalScore = 0;
    GameState currentState = state;
    GameMove currentMove = initialMove;
    int chainLength = 0;

    while (true) {
      // Apply the current move
      currentState = CheckersRules.applyMove(currentState, currentMove);
      chainLength++;

      // Evaluate the position after this move
      totalScore += _evaluateBoard(currentState) * (1.0 / chainLength); // Diminishing returns for longer chains

      // Check if there are additional jumps available
      if (currentState.validMoves.isEmpty) {
        break;
      }

      // Find the best next move in the chain
      GameMove? bestNextMove;
      double bestNextScore = double.negativeInfinity;

      for (final nextMove in currentState.validMoves) {
        final nextState = CheckersRules.applyMove(currentState, nextMove);
        final nextScore = _evaluateBoard(nextState);
        
        if (nextScore > bestNextScore) {
          bestNextScore = nextScore;
          bestNextMove = nextMove;
        }
      }

      if (bestNextMove == null) {
        break;
      }

      currentMove = bestNextMove;
    }

    return totalScore;
  }

  static double _minimax(
    GameState state,
    int depth,
    double alpha,
    double beta,
    bool isMaximizing,
  ) {
    if (depth == 0 || state.isGameOver) {
      return _evaluateBoard(state);
    }

    final moves = <GameMove>[];
    // Get moves for the current player in the state
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.getPiece(row, col);
        if (piece != null && piece.type == state.currentPlayer) {
          moves.addAll(CheckersRules.getValidMoves(state, piece));
        }
      }
    }

    if (moves.isEmpty) return _evaluateBoard(state);

    if (isMaximizing) {
      double maxScore = double.negativeInfinity;
      for (final move in moves) {
        final newState = CheckersRules.applyMove(state, move);
        final score = _minimax(newState, depth - 1, alpha, beta, false);
        maxScore = maxScore > score ? maxScore : score;
        alpha = alpha > score ? alpha : score;
        if (beta <= alpha) break;
      }
      return maxScore;
    } else {
      double minScore = double.infinity;
      for (final move in moves) {
        final newState = CheckersRules.applyMove(state, move);
        final score = _minimax(newState, depth - 1, alpha, beta, true);
        minScore = minScore < score ? minScore : score;
        beta = beta < score ? beta : score;
        if (beta <= alpha) break;
      }
      return minScore;
    }
  }

  static double _evaluateBoard(GameState state) {
    if (state.status == GameStatus.redWon) return 1000;
    if (state.status == GameStatus.blackWon) return -1000;
    if (state.status == GameStatus.draw) return 0;

    double score = 0;
    int redPieces = 0;
    int blackPieces = 0;
    int redKings = 0;
    int blackKings = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.getPiece(row, col);
        if (piece != null) {
          if (piece.isRed) {
            redPieces++;
            if (piece.isKing) redKings++;
            // Bonus for pieces closer to promotion
            score += (7 - row) * 0.1;
          } else {
            blackPieces++;
            if (piece.isKing) blackKings++;
            // Bonus for pieces closer to promotion
            score -= row * 0.1;
          }
        }
      }
    }

    // Piece count evaluation (balanced weights)
    score += (redPieces - blackPieces) * 15;
    score += (redKings - blackKings) * 20;

    // Balanced evaluation - consider both attacking and defensive opportunities
    score += _evaluateAttackingOpportunities(state);

    // Position evaluation
    score += _evaluatePosition(state);

    return score;
  }

  static double _evaluateAttackingOpportunities(GameState state) {
    double score = 0;

    // Evaluate attacking opportunities for both sides
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.getPiece(row, col);
        if (piece != null) {
          // Check if this piece can capture opponent pieces
          final jumpMoves = CheckersRules.getJumpMoves(state, piece);
          if (jumpMoves.isNotEmpty) {
            // Balanced bonus for having capturing opportunities
            if (piece.isRed) {
              score += jumpMoves.length * 10; // Moderate bonus for red
            } else {
              score -=
                  jumpMoves.length *
                  10; // Moderate penalty for black having captures
            }
          }

          // Bonus for pieces that are close to opponent pieces (potential captures)
          score += _evaluateProximityToOpponent(state, piece);
        }
      }
    }

    return score;
  }

  static double _evaluateProximityToOpponent(
    GameState state,
    CheckerPiece piece,
  ) {
    double score = 0;
    final opponentType = piece.isRed ? PieceType.black : PieceType.red;

    // Check adjacent squares for opponent pieces
    final directions = piece.isKing ? [-1, 1] : (piece.isRed ? [-1] : [1]);
    final cols = [-1, 1];

    for (final rowDir in directions) {
      for (final colDir in cols) {
        final adjacentRow = piece.row + rowDir;
        final adjacentCol = piece.col + colDir;

        if (adjacentRow >= 0 &&
            adjacentRow < 8 &&
            adjacentCol >= 0 &&
            adjacentCol < 8) {
          final adjacentPiece = state.getPiece(adjacentRow, adjacentCol);
          if (adjacentPiece != null && adjacentPiece.type == opponentType) {
            // Check if we can jump over this piece
            final jumpRow = piece.row + (rowDir * 2);
            final jumpCol = piece.col + (colDir * 2);

            if (jumpRow >= 0 && jumpRow < 8 && jumpCol >= 0 && jumpCol < 8) {
              final jumpSquare = state.getPiece(jumpRow, jumpCol);
                          if (jumpSquare == null) {
              // This is a potential capture opportunity
              if (piece.isRed) {
                score += 5; // Moderate bonus for red having capture opportunity
              } else {
                score -= 5; // Moderate penalty for black having capture opportunity
              }
            }
            }
          }
        }
      }
    }

    return score;
  }

  static double _evaluatePosition(GameState state) {
    double score = 0;

    // Center control bonus
    for (int row = 3; row < 5; row++) {
      for (int col = 3; col < 5; col++) {
        final piece = state.getPiece(row, col);
        if (piece != null) {
          if (piece.isRed) {
            score += 2;
          } else {
            score -= 2;
          }
        }
      }
    }

    // Edge safety bonus
    for (int col = 0; col < 8; col++) {
      final topPiece = state.getPiece(0, col);
      final bottomPiece = state.getPiece(7, col);

      if (topPiece != null && topPiece.isRed) score += 1;
      if (bottomPiece != null && bottomPiece.isBlack) score -= 1;
    }

    return score;
  }
}
