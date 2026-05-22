import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodDbProvider with ChangeNotifier {
  final List<FoodItem> _foods = [
    FoodItem(name: 'Egg', caloriesPerServing: 78, servingSize: '1 large'),
    FoodItem(name: 'Chicken Breast', caloriesPerServing: 165, servingSize: '100g'),
    FoodItem(name: 'White Rice', caloriesPerServing: 130, servingSize: '100g cooked'),
    FoodItem(name: 'Apple', caloriesPerServing: 95, servingSize: '1 medium'),
    FoodItem(name: 'Banana', caloriesPerServing: 105, servingSize: '1 medium'),
    FoodItem(name: 'Oats', caloriesPerServing: 389, servingSize: '100g dry'),
    FoodItem(name: 'Almonds', caloriesPerServing: 579, servingSize: '100g'),
    FoodItem(name: 'Milk (Whole)', caloriesPerServing: 150, servingSize: '1 cup'),
  ];

  List<FoodItem> get foods => _foods;

  List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) return _foods;
    final lowerQuery = query.toLowerCase();
    return _foods.where((f) => f.name.toLowerCase().contains(lowerQuery)).toList();
  }

  void addFood(FoodItem item) {
    _foods.add(item);
    notifyListeners();
  }
}
