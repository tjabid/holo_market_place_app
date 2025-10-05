import 'package:flutter/material.dart';
import 'package:holo_market_place_app/features/products/domain/entities/product/category.dart';

Category mapStringToCategory(String category, bool isSelected) {
  return Category(
    id: category.toLowerCase(),
    displayName: getCategoryDisplayName(category),
    icon: getCategoryIcon(category),
    isSelected: isSelected,
  );
}

String getCategoryDisplayName(String category) {
  switch (category.toLowerCase()) {
    case 'all':
      return 'All';
    case "men's clothing":
      return 'Men';
    case "women's clothing":
      return 'Women';
    default:
      // Capitalize first letter of the default category
      return category.isNotEmpty 
          ? category[0].toUpperCase() + category.substring(1).toLowerCase()
          : category;
  }
}

IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.category;
      case "men's clothing":
      case 'mens clothing':
        return Icons.male;
      case "women's clothing":
      case 'womens clothing':
        return Icons.female;
      case 'jewelery':
      case 'jewelry':
        return Icons.diamond_outlined;
      case 'electronics':
        return Icons.devices;
      default:
        return Icons.category;
    }
  }