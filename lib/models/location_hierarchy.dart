class LocationHierarchy {
  final String stateName;
  final String districtName;
  final String tahsilName;
  final String blockName;

  LocationHierarchy({
    required this.stateName,
    required this.districtName,
    required this.tahsilName,
    required this.blockName,
  });

  @override
  String toString() {
    return '$blockName, $tahsilName, $districtName, $stateName';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationHierarchy &&
        other.stateName == stateName &&
        other.districtName == districtName &&
        other.tahsilName == tahsilName &&
        other.blockName == blockName;
  }

  @override
  int get hashCode {
    return Object.hash(stateName, districtName, tahsilName, blockName);
  }
}

class FilterState {
  final String? selectedState;
  final String? selectedDistrict;
  final String? selectedTahsil;
  final String? selectedBlock;

  FilterState({
    this.selectedState,
    this.selectedDistrict,
    this.selectedTahsil,
    this.selectedBlock,
  });

  FilterState copyWith({
    String? selectedState,
    String? selectedDistrict,
    String? selectedTahsil,
    String? selectedBlock,
    bool clearDistrict = false,
    bool clearTahsil = false,
    bool clearBlock = false,
  }) {
    return FilterState(
      selectedState: selectedState ?? this.selectedState,
      selectedDistrict: clearDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      selectedTahsil: clearTahsil ? null : (selectedTahsil ?? this.selectedTahsil),
      selectedBlock: clearBlock ? null : (selectedBlock ?? this.selectedBlock),
    );
  }

  bool get hasAnySelection => 
      selectedState != null || 
      selectedDistrict != null || 
      selectedTahsil != null || 
      selectedBlock != null;

  @override
  String toString() {
    final parts = <String>[];
    if (selectedBlock != null) parts.add('Block: $selectedBlock');
    if (selectedTahsil != null) parts.add('Tahsil: $selectedTahsil');
    if (selectedDistrict != null) parts.add('District: $selectedDistrict');
    if (selectedState != null) parts.add('State: $selectedState');
    return parts.isEmpty ? 'No filters applied' : parts.join(', ');
  }
}