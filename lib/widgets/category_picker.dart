import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class CategoryPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          GestureDetector(
            onTap: () => onSelected(category),
            child: Container(
              width: 100,
              height: 76,
              decoration: BoxDecoration(
                color: category == selected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: category == selected
                      ? primary
                      : const Color(0xFFE3DEF5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcon(category),
                    color: category == selected ? Colors.white : primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: category == selected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
