import 'package:flutter/material.dart';

class FilterOptions {
  String sortBy;
  RangeValues priceRange;
  Set<String> categories;

  FilterOptions({
    this.sortBy = 'Popularity',
    this.priceRange = const RangeValues(0, 100),
    Set<String>? categories,
  }) : categories = categories ?? {};

  FilterOptions copyWith({
    String? sortBy,
    RangeValues? priceRange,
    Set<String>? categories,
  }) {
    return FilterOptions(
      sortBy: sortBy ?? this.sortBy,
      priceRange: priceRange ?? this.priceRange,
      categories: categories ?? this.categories,
    );
  }
}