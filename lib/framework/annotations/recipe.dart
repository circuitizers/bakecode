class RecipeCategory {
  final List<String> sections;
  const RecipeCategory(this.sections) : assert(sections != null);
}

class RecipeImage {
  final String resourceUrl;
  const RecipeImage(this.resourceUrl) : assert(resourceUrl != null);
}

class RecipeSummary {
  final String summary;
  const RecipeSummary(this.summary) : assert(summary != null);
}
