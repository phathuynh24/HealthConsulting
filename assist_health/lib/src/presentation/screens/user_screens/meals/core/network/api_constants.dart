class ApiConstants {
  static const String baseUrl = "http://172.21.1.245:5001";

  // Endpoints
  static const String suggestRecipesEndpoint =
      "/recommendation/suggest-recipes";
  static const String predictNutritionEndpoint = "/nutrition/predict";
  static const String getTranslateEndpoint = "/translate";

  // Full URLs
  static String getSuggestRecipesUrl() => "$baseUrl$suggestRecipesEndpoint";
  static String getPredictNutritionUrl() => "$baseUrl$predictNutritionEndpoint";
  static String getTranslateUrl() => "$baseUrl$getTranslateEndpoint";
}
