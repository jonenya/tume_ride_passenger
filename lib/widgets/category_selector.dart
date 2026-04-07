import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String description;
  final double multiplier;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.multiplier = 1.0,
  });
}

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Category> categories = [
    Category(id: 'bikes', name: 'Bikes', icon: '🏍️', description: 'Quick & affordable'),
    Category(id: 'electric_bikes', name: 'E-Bikes', icon: '⚡🏍️', description: 'Eco-friendly'),
    Category(id: 'tuktuk', name: 'TukTuk', icon: '🛺', description: '3-wheeler'),
    Category(id: 'basic_car', name: 'Basic', icon: '🚗', description: 'Standard ride'),
    Category(id: 'basic_electric', name: 'E-Car', icon: '🔋🚗', description: 'Electric vehicle'),
    Category(id: 'women_only', name: 'Women Only', icon: '👩', description: 'Female drivers'),
    Category(id: 'send_parcel', name: 'Send Parcel', icon: '📦', description: 'Package delivery'),
    Category(id: 'comfort', name: 'Comfort', icon: '✨🚗', description: 'Extra comfort'),
    Category(id: 'comfort_electric', name: 'E-Comfort', icon: '✨🔋', description: 'Premium electric'),
    Category(id: 'xl_7_seater', name: 'XL 7-Seater', icon: '🚙', description: 'Large groups'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.id;
          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}