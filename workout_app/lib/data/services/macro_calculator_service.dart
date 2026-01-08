// Service utilitaire pure, pas de constucteur, pas d'état.
class MacroCalculatorService {
  // il s'agit juste d'un calcul (entrée -> sortie), donc pas besoin d'instance => static et non factory
  // Map<String, double> = type-safe, meilleur que dynamic
  static Map<String, double> calculate({
    required int age,
    required double weight,
    required int height,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // BMR (Mifflin-St Jeor)
    double bmr;
    if (gender == "Homme") {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Facteur activité
    double activityFactor = {
      "Sédentaire": 1.2,
      "Léger": 1.375,
      "Modéré": 1.55,
      "Intense": 1.725,
      "Extreme": 1.9,
    }[activityLevel]!;

    double tdee = bmr * activityFactor;

    // Ajuste selon objectif
    double caloriesTarget;
    if (goal == "Perte") {
      caloriesTarget = tdee - 500; // Déficit
    } else if (goal == "Prise") {
      caloriesTarget = tdee + 300; // Surplus
    } else {
      caloriesTarget = tdee; // Maintien
    }

    // Macros
    double proteinsTarget = weight * 2.0; // 2g/kg
    double fatsTarget = caloriesTarget * 0.25 / 9; // 25% des calories
    double carbsTarget =
        (caloriesTarget - (proteinsTarget * 4) - (fatsTarget * 9)) / 4;

    print("carbs : $carbsTarget");
    return {
      "caloriesTarget": caloriesTarget,
      "carbsTarget": carbsTarget,
      "proteinsTarget": proteinsTarget,
      "fatsTarget": fatsTarget,
    };
  }
}
