enum SectionName { favorite, recipes, library }

extension SectionNameExtension on SectionName {
  String get label {
    switch (this) {
      case SectionName.favorite:
        return 'Bibliothèque';
      case SectionName.recipes:
        return 'Recettes';
      case SectionName.library:
        return 'Favoris';
    }
  }
}
