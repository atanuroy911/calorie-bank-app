class FoodItem {
  final String name;
  final int caloriesPerServing;
  final String servingSize;

  FoodItem({
    required this.name,
    required this.caloriesPerServing,
    required this.servingSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'caloriesPerServing': caloriesPerServing,
      'servingSize': servingSize,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      caloriesPerServing: json['caloriesPerServing'] as int,
      servingSize: json['servingSize'] as String,
    );
  }
}
