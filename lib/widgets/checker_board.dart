import 'package:flutter/material.dart';
import '../models/checker_piece.dart';
import '../models/game_state.dart';

class CheckerBoard extends StatelessWidget {
  final GameState gameState;
  final Function(CheckerPiece) onPieceSelected;
  final Function(int, int) onSquareTapped;
  final AnimationController moveController;

  const CheckerBoard({
    super.key,
    required this.gameState,
    required this.onPieceSelected,
    required this.onSquareTapped,
    required this.moveController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize = size.width < size.height
        ? size.width * 0.8
        : size.height * 0.6;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final isLightSquare = (row + col) % 2 == 0;
            final piece = gameState.getPiece(row, col);
            final isSelected = gameState.selectedPiece == piece;
            final isValidMove = gameState.validMoves.any(
              (move) => move.toRow == row && move.toCol == col,
            );

            return GestureDetector(
              onTap: () => onSquareTapped(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isLightSquare
                      ? const Color(0xFFF5F5DC)
                      : const Color(0xFF8B4513),
                  border: isSelected
                      ? Border.all(color: Colors.yellow, width: 4)
                      : null,
                ),
                child: Stack(
                  children: [
                    if (isValidMove)
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    if (piece != null)
                      Center(
                        child: _CheckerPiece(
                          piece: piece,
                          isSelected: isSelected,
                          onTap: () => onPieceSelected(piece),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckerPiece extends StatelessWidget {
  final CheckerPiece piece;
  final bool isSelected;
  final VoidCallback onTap;

  const _CheckerPiece({
    required this.piece,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: piece.isRed
                ? [
                    const Color(0xFFEF4444),
                    const Color(0xFFDC2626),
                    const Color(0xFFB91C1C),
                  ]
                : [
                    const Color(0xFF374151),
                    const Color(0xFF1F2937),
                    const Color(0xFF111827),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: piece.isKing
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: piece.isRed
                        ? [
                            const Color(0xFFEF4444),
                            const Color(0xFFDC2626),
                            const Color(0xFFB91C1C),
                          ]
                        : [
                            const Color(0xFF374151),
                            const Color(0xFF1F2937),
                            const Color(0xFF111827),
                          ],
                  ),
                ),
                child: Icon(Icons.star, color: Colors.white, size: 20),
              )
            : null,
      ),
    );
  }
}
