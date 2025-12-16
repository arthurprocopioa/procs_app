import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String id;
  final String title;
  final String food;
  final String subtext; // e.g. preparation info
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onSwap; // Feature PRO
  final VoidCallback onRecipe; // Open recipe

  const MealCard({
    super.key,
    required this.id,
    required this.title,
    required this.food,
    required this.subtext,
    required this.isCompleted,
    required this.onToggle,
    required this.onSwap,
    required this.onRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? colorScheme.primary.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: colorScheme.primary, // Gold
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          // Shuffle Button (PRO)
                          InkWell(
                            onTap: onSwap,
                            child: const Icon(Icons.shuffle,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        food,
                        style: TextStyle(
                          color: isCompleted ? Colors.white54 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: onRecipe,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              "Ver preparo",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Checkbox Big
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: (v) => onToggle(),
                    activeColor: colorScheme.primary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
