import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/checker_piece.dart';

class GameInfo extends StatelessWidget {
  final GameState gameState;
  final bool isAITurn;
  final AnimationController aiThinkingController;

  const GameInfo({
    super.key,
    required this.gameState,
    required this.isAITurn,
    required this.aiThinkingController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Player Indicator
          Expanded(child: _buildPlayerIndicator()),

          // AI Thinking Indicator or Game Status
          if (isAITurn)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildAIThinkingIndicator(),
              ),
            )
          else if (gameState.isGameOver)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildGameStatus(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gameState.currentPlayer == PieceType.red
                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                    : [const Color(0xFF374151), const Color(0xFF1F2937)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            gameState.currentPlayer == PieceType.red ? 'Your Turn' : 'AI Turn',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIThinkingIndicator() {
    return AnimatedBuilder(
      animation: aiThinkingController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.orange.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.orange.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.orange.shade300,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Thinking...',
                style: TextStyle(
                  color: Colors.orange.shade100,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameStatus() {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.3), statusColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (gameState.status) {
      case GameStatus.redWon:
        return Colors.green.shade400;
      case GameStatus.blackWon:
        return Colors.red.shade400;
      case GameStatus.draw:
        return Colors.orange.shade400;
      default:
        return Colors.white;
    }
  }

  String _getStatusText() {
    switch (gameState.status) {
      case GameStatus.redWon:
        return 'You Won!';
      case GameStatus.blackWon:
        return 'AI Won!';
      case GameStatus.draw:
        return 'Draw!';
      default:
        return '';
    }
  }

  IconData _getStatusIcon() {
    switch (gameState.status) {
      case GameStatus.redWon:
        return Icons.emoji_events;
      case GameStatus.blackWon:
        return Icons.sentiment_dissatisfied;
      case GameStatus.draw:
        return Icons.handshake;
      default:
        return Icons.info;
    }
  }
}
