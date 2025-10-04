import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.context,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final BuildContext context;
  final List<Category> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) {
          debugPrint(
              'Rendering category: ${category.id}, selectedCategory: $selectedCategory');
          final isSelected = category.id == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? 
                    (isDark ? Colors.white : Colors.black) : 
                    (isDark ? Colors.grey[900] : Colors.white),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    category.icon,
                    color: isSelected
                        ? (isDark ? Colors.grey[600] : Colors.white)
                        : (isDark ? Colors.white : Colors.grey[600]),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                    ? (isDark ? Colors.white : Colors.black) 
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
