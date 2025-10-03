import 'package:flutter/material.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 18,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => onCategorySelected(category),
              backgroundColor: Colors.white,
              selectedColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all items':
        return Icons.apps;
      case "men's clothing":
      case 'mens clothing':
        return Icons.checkroom_outlined;
      case "women's clothing":
      case 'womens clothing':
        return Icons.checkroom;
      case 'jewelery':
      case 'jewelry':
        return Icons.diamond_outlined;
      case 'electronics':
        return Icons.devices;
      default:
        return Icons.category;
    }
  }
}
