import 'package:flutter/material.dart';
import '../models/checker_piece.dart';
import '../models/game_move.dart';
import '../models/game_state.dart';
import '../game_logic/checkers_rules.dart';
import '../ai/checkers_ai.dart';
import '../widgets/checker_board.dart';
import '../widgets/game_info.dart';
import '../widgets/game_dialogs.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _gameState;
  late AnimationController _moveController;
  late AnimationController _aiThinkingController;
  late AnimationController _fadeController;
  bool _isAITurn = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupAnimations();
  }

  void _initializeGame() {
    final board = CheckersRules.createInitialBoard();
    _gameState = GameState(board: board);
  }

  void _setupAnimations() {
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _aiThinkingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _moveController.dispose();
    _aiThinkingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPieceSelected(CheckerPiece piece) {
    if (_isAITurn || piece.type != _gameState.currentPlayer) return;

    // If there are valid moves from a previous jump, only allow selecting the piece that can continue
    if (_gameState.validMoves.isNotEmpty) {
      // Check if this piece can continue the chain attack
      final canContinue = _gameState.validMoves.any((move) => move.piece == piece);
      if (!canContinue) return;
    }

    final validMoves = CheckersRules.getValidMoves(_gameState, piece);

    setState(() {
      _gameState = _gameState.copyWith(
        selectedPiece: piece,
        validMoves: validMoves,
      );
    });
  }

  void _onSquareTapped(int row, int col) {
    if (_isAITurn) return;

    final selectedPiece = _gameState.selectedPiece;
    if (selectedPiece == null) return;

    // Check if this is a valid move
    final validMove = _gameState.validMoves.firstWhere(
      (move) => move.toRow == row && move.toCol == col,
      orElse: () => GameMove(
        piece: selectedPiece,
        fromRow: selectedPiece.row,
        fromCol: selectedPiece.col,
        toRow: -1,
        toCol: -1,
      ),
    );

    if (validMove.toRow == -1) return;

    _makeMove(validMove);
  }

  void _makeMove(GameMove move) async {
    setState(() {
      _gameState = CheckersRules.applyMove(_gameState, move);
      _isAITurn = _gameState.currentPlayer == PieceType.black;
    });

    if (_gameState.isGameOver) {
      _showGameOverDialog();
      return;
    }

    if (_isAITurn) {
      _aiThinkingController.repeat();

      // Add a small delay to make AI thinking visible
      await Future.delayed(const Duration(milliseconds: 500));

      // Handle AI moves including chain attacks
      await _makeAIMove();

      if (_gameState.isGameOver) {
        _showGameOverDialog();
      }
    }
  }

  Future<void> _makeAIMove() async {
    while (_gameState.currentPlayer == PieceType.black && !_gameState.isGameOver) {
      final aiMove = CheckersAI.getBestMove(_gameState);
      
      setState(() {
        _gameState = CheckersRules.applyMove(_gameState, aiMove);
        _isAITurn = _gameState.currentPlayer == PieceType.black;
      });

      // If the AI made a jump and there are additional jumps available, continue
      if (aiMove.isJump && _gameState.validMoves.isNotEmpty) {
        // Small delay between chain moves for visual effect
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        // No more moves for AI, switch to player
        _isAITurn = false;
        break;
      }
    }
    
    _aiThinkingController.stop();
  }

  void _showGameOverDialog() {
    GameDialogs.showGameOverDialog(
      context,
      _gameState,
      () {
        Navigator.pop(context);
        _resetGame();
      },
      () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      _isAITurn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeController,
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'CHECKERS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _resetGame,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        tooltip: 'New Game',
                      ),
                    ],
                  ),
                ),

                // Game Info
                GameInfo(
                  gameState: _gameState,
                  isAITurn: _isAITurn,
                  aiThinkingController: _aiThinkingController,
                ),

                const SizedBox(height: 20),

                // Game Board
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CheckerBoard(
                          gameState: _gameState,
                          onPieceSelected: _onPieceSelected,
                          onSquareTapped: _onSquareTapped,
                          moveController: _moveController,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
