import 'package:equatable/equatable.dart';

// ── Macronutrients ────────────────────────────────────────────────────────────

class Macros extends Equatable {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double saturatedFatG;
  final double transFatG;
  final double cholesterolMg;

  const Macros({
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
    this.saturatedFatG = 0,
    this.transFatG = 0,
    this.cholesterolMg = 0,
  });

  Macros operator +(Macros other) => Macros(
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
        fiberG: fiberG + other.fiberG,
        sugarG: sugarG + other.sugarG,
        saturatedFatG: saturatedFatG + other.saturatedFatG,
        transFatG: transFatG + other.transFatG,
        cholesterolMg: cholesterolMg + other.cholesterolMg,
      );

  Macros copyWith({
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? sugarG,
    double? saturatedFatG,
    double? transFatG,
    double? cholesterolMg,
  }) =>
      Macros(
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        fiberG: fiberG ?? this.fiberG,
        sugarG: sugarG ?? this.sugarG,
        saturatedFatG: saturatedFatG ?? this.saturatedFatG,
        transFatG: transFatG ?? this.transFatG,
        cholesterolMg: cholesterolMg ?? this.cholesterolMg,
      );

  Map<String, dynamic> toJson() => {
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sugar_g': sugarG,
        'saturated_fat_g': saturatedFatG,
        'trans_fat_g': transFatG,
        'cholesterol_mg': cholesterolMg,
      };

  factory Macros.fromJson(Map<String, dynamic> j) => Macros(
        proteinG: _d(j['protein_g']),
        carbsG: _d(j['carbs_g']),
        fatG: _d(j['fat_g']),
        fiberG: _d(j['fiber_g']),
        sugarG: _d(j['sugar_g']),
        saturatedFatG: _d(j['saturated_fat_g']),
        transFatG: _d(j['trans_fat_g']),
        cholesterolMg: _d(j['cholesterol_mg']),
      );

  @override
  List<Object?> get props =>
      [proteinG, carbsG, fatG, fiberG, sugarG, saturatedFatG, transFatG, cholesterolMg];
}

// ── Micronutrients ────────────────────────────────────────────────────────────

class Micros extends Equatable {
  // Minerals (mg)
  final double sodiumMg;
  final double potassiumMg;
  final double calciumMg;
  final double ironMg;
  final double magnesiumMg;
  final double zincMg;
  final double phosphorusMg;

  // Vitamins
  final double vitaminCMg;   // mg
  final double vitaminDUg;   // μg (micrograms)
  final double vitaminB12Ug; // μg
  final double folateMcg;    // μg (DFE)
  final double vitaminAUg;   // μg RAE
  final double vitaminEMg;   // mg
  final double vitaminKUg;   // μg

  const Micros({
    this.sodiumMg = 0,
    this.potassiumMg = 0,
    this.calciumMg = 0,
    this.ironMg = 0,
    this.magnesiumMg = 0,
    this.zincMg = 0,
    this.phosphorusMg = 0,
    this.vitaminCMg = 0,
    this.vitaminDUg = 0,
    this.vitaminB12Ug = 0,
    this.folateMcg = 0,
    this.vitaminAUg = 0,
    this.vitaminEMg = 0,
    this.vitaminKUg = 0,
  });

  Micros operator +(Micros other) => Micros(
        sodiumMg: sodiumMg + other.sodiumMg,
        potassiumMg: potassiumMg + other.potassiumMg,
        calciumMg: calciumMg + other.calciumMg,
        ironMg: ironMg + other.ironMg,
        magnesiumMg: magnesiumMg + other.magnesiumMg,
        zincMg: zincMg + other.zincMg,
        phosphorusMg: phosphorusMg + other.phosphorusMg,
        vitaminCMg: vitaminCMg + other.vitaminCMg,
        vitaminDUg: vitaminDUg + other.vitaminDUg,
        vitaminB12Ug: vitaminB12Ug + other.vitaminB12Ug,
        folateMcg: folateMcg + other.folateMcg,
        vitaminAUg: vitaminAUg + other.vitaminAUg,
        vitaminEMg: vitaminEMg + other.vitaminEMg,
        vitaminKUg: vitaminKUg + other.vitaminKUg,
      );

  Micros copyWith({
    double? sodiumMg,
    double? potassiumMg,
    double? calciumMg,
    double? ironMg,
    double? magnesiumMg,
    double? zincMg,
    double? phosphorusMg,
    double? vitaminCMg,
    double? vitaminDUg,
    double? vitaminB12Ug,
    double? folateMcg,
    double? vitaminAUg,
    double? vitaminEMg,
    double? vitaminKUg,
  }) =>
      Micros(
        sodiumMg: sodiumMg ?? this.sodiumMg,
        potassiumMg: potassiumMg ?? this.potassiumMg,
        calciumMg: calciumMg ?? this.calciumMg,
        ironMg: ironMg ?? this.ironMg,
        magnesiumMg: magnesiumMg ?? this.magnesiumMg,
        zincMg: zincMg ?? this.zincMg,
        phosphorusMg: phosphorusMg ?? this.phosphorusMg,
        vitaminCMg: vitaminCMg ?? this.vitaminCMg,
        vitaminDUg: vitaminDUg ?? this.vitaminDUg,
        vitaminB12Ug: vitaminB12Ug ?? this.vitaminB12Ug,
        folateMcg: folateMcg ?? this.folateMcg,
        vitaminAUg: vitaminAUg ?? this.vitaminAUg,
        vitaminEMg: vitaminEMg ?? this.vitaminEMg,
        vitaminKUg: vitaminKUg ?? this.vitaminKUg,
      );

  Map<String, dynamic> toJson() => {
        'sodium_mg': sodiumMg,
        'potassium_mg': potassiumMg,
        'calcium_mg': calciumMg,
        'iron_mg': ironMg,
        'magnesium_mg': magnesiumMg,
        'zinc_mg': zincMg,
        'phosphorus_mg': phosphorusMg,
        'vitamin_c_mg': vitaminCMg,
        'vitamin_d_ug': vitaminDUg,
        'vitamin_b12_ug': vitaminB12Ug,
        'folate_mcg': folateMcg,
        'vitamin_a_ug': vitaminAUg,
        'vitamin_e_mg': vitaminEMg,
        'vitamin_k_ug': vitaminKUg,
      };

  factory Micros.fromJson(Map<String, dynamic> j) => Micros(
        sodiumMg: _d(j['sodium_mg']),
        potassiumMg: _d(j['potassium_mg']),
        calciumMg: _d(j['calcium_mg']),
        ironMg: _d(j['iron_mg']),
        magnesiumMg: _d(j['magnesium_mg']),
        zincMg: _d(j['zinc_mg']),
        phosphorusMg: _d(j['phosphorus_mg']),
        vitaminCMg: _d(j['vitamin_c_mg']),
        vitaminDUg: _d(j['vitamin_d_ug']),
        vitaminB12Ug: _d(j['vitamin_b12_ug']),
        folateMcg: _d(j['folate_mcg']),
        vitaminAUg: _d(j['vitamin_a_ug']),
        vitaminEMg: _d(j['vitamin_e_mg']),
        vitaminKUg: _d(j['vitamin_k_ug']),
      );

  @override
  List<Object?> get props => [
        sodiumMg, potassiumMg, calciumMg, ironMg, magnesiumMg, zincMg,
        phosphorusMg, vitaminCMg, vitaminDUg, vitaminB12Ug, folateMcg,
        vitaminAUg, vitaminEMg, vitaminKUg,
      ];
}

// ── Reference Daily Values (FDA / WHO) ────────────────────────────────────────

class DailyReferenceValues {
  // Macros
  static const double fiberG = 28;
  static const double sugarG = 50;        // <10% of 2000 kcal
  static const double saturatedFatG = 20; // <10% of 2000 kcal
  static const double cholesterolMg = 300;

  // Minerals
  static const double sodiumMg = 2300;
  static const double potassiumMg = 4700;
  static const double calciumMg = 1300;
  static const double ironMg = 18;
  static const double magnesiumMg = 420;
  static const double zincMg = 11;
  static const double phosphorusMg = 1250;

  // Vitamins
  static const double vitaminCMg = 90;
  static const double vitaminDUg = 20;
  static const double vitaminB12Ug = 2.4;
  static const double folateMcg = 400;
  static const double vitaminAUg = 900;
  static const double vitaminEMg = 15;
  static const double vitaminKUg = 120;
}

// ── Private helper ────────────────────────────────────────────────────────────
double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
