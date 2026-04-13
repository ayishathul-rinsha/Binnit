/// Enum representing different waste categories
enum WasteCategory {
  plastic,
  paper,
  organic,
  metal,
  ewaste,
}

extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.plastic:
        return 'Plastic';
      case WasteCategory.paper:
        return 'Paper';
      case WasteCategory.organic:
        return 'Organic';
      case WasteCategory.metal:
        return 'Metal';
      case WasteCategory.ewaste:
        return 'E-Waste';
    }
  }

  String get icon {
    switch (this) {
      case WasteCategory.plastic:
        return '♻️';
      case WasteCategory.paper:
        return '📄';
      case WasteCategory.organic:
        return '🌱';
      case WasteCategory.metal:
        return '🔩';
      case WasteCategory.ewaste:
        return '💻';
    }
  }

  String get backendValue {
    return name.toLowerCase();
  }

  static WasteCategory fromString(String value) {
    final normalized = value.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (normalized.contains('plastic') || normalized.contains('glass')) {
      return WasteCategory.plastic;
    } else if (normalized.contains('paper') || normalized.contains('textile')) {
      return WasteCategory.paper;
    } else if (normalized.contains('organic') || normalized.contains('kitchen')) {
      return WasteCategory.organic;
    } else if (normalized.contains('metal')) {
      return WasteCategory.metal;
    } else if (normalized.contains('ewaste') || normalized.contains('electronic') || normalized.contains('hazardous')) {
      return WasteCategory.ewaste;
    }
    return WasteCategory.plastic; // Fallback
  }
}
