/// Enum representing different waste categories
enum WasteCategory {
  dryWaste,
  wetWaste,
  eWaste,
  recyclables,
  hazardous,
}

extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.dryWaste:
        return 'Dry Waste';
      case WasteCategory.wetWaste:
        return 'Wet Waste';
      case WasteCategory.eWaste:
        return 'E-Waste';
      case WasteCategory.recyclables:
        return 'Recyclables';
      case WasteCategory.hazardous:
        return 'Hazardous';
    }
  }

  String get icon {
    switch (this) {
      case WasteCategory.dryWaste:
        return '📦';
      case WasteCategory.wetWaste:
        return '🥗';
      case WasteCategory.eWaste:
        return '💻';
      case WasteCategory.recyclables:
        return '♻️';
      case WasteCategory.hazardous:
        return '☢️';
    }
  }
}
