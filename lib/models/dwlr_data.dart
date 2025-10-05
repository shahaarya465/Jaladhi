class DwlrData {
  final String id;
  final String stateName;
  final String districtName;
  final String tahsilName;
  final String blockName;
  final String siteName;
  final String siteType;
  final String siteSubType;
  final String aquiferType;
  final double depth;
  final DateTime wlsDate;
  final double waterLevel;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String wellType;
  final Map<String, dynamic> additionalData;

  DwlrData({
    required this.id,
    required this.stateName,
    required this.districtName,
    required this.tahsilName,
    required this.blockName,
    required this.siteName,
    required this.siteType,
    required this.siteSubType,
    required this.aquiferType,
    required this.depth,
    required this.wlsDate,
    required this.waterLevel,
    this.latitude = 0.0,
    this.longitude = 0.0,
    DateTime? timestamp,
    String? wellType,
    this.additionalData = const {},
  }) : timestamp = timestamp ?? DateTime.now(),
       wellType = wellType ?? siteType;

  // Backward compatibility getters
  String get location => '$siteName, $blockName, $districtName, $stateName';

  factory DwlrData.fromJson(Map<String, dynamic> json) {
    return DwlrData(
      id: json['id'] ?? json['SITE_ID'] ?? '',
      stateName: json['stateName'] ?? json['STATE_NAME'] ?? '',
      districtName: json['districtName'] ?? json['DISTRICT_NAME'] ?? '',
      tahsilName: json['tahsilName'] ?? json['TAHSIL_NAME'] ?? '',
      blockName: json['blockName'] ?? json['BLOCK_NAME'] ?? '',
      siteName: json['siteName'] ?? json['SITE_NAME'] ?? '',
      siteType: json['siteType'] ?? json['SITE_TYPE'] ?? '',
      siteSubType: json['siteSubType'] ?? json['SITE_SUB_TYPE'] ?? '',
      aquiferType: json['aquiferType'] ?? json['AQUIFER_TYPE'] ?? '',
      depth: _parseDouble(json['depth'] ?? json['DEPTH']),
      wlsDate: _parseDate(json['wlsDate'] ?? json['WLS_DATE']),
      waterLevel: _parseDouble(json['waterLevel'] ?? json['WLS_WTR_LEVE']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      timestamp: json['timestamp'] != null ? _parseDate(json['timestamp']) : DateTime.now(),
      wellType: json['wellType'] ?? json['SITE_TYPE'],
      additionalData: json['additionalData'] ?? {},
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        // Handle DD-MMM-YY format (e.g., "30-Nov-22")
        if (value.contains('-') && value.length <= 10) {
          final parts = value.split('-');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]) ?? 1;
            final month = _monthNameToNumber(parts[1]);
            var year = int.tryParse(parts[2]) ?? DateTime.now().year;
            
            // Handle 2-digit years
            if (year < 100) {
              year += (year > 50) ? 1900 : 2000;
            }
            
            return DateTime(year, month, day);
          }
        }
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static int _monthNameToNumber(String monthName) {
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    return months[monthName.toLowerCase().substring(0, 3)] ?? 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stateName': stateName,
      'districtName': districtName,
      'tahsilName': tahsilName,
      'blockName': blockName,
      'siteName': siteName,
      'siteType': siteType,
      'siteSubType': siteSubType,
      'aquiferType': aquiferType,
      'depth': depth,
      'wlsDate': wlsDate.toIso8601String(),
      'waterLevel': waterLevel,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'wellType': wellType,
      'additionalData': additionalData,
    };
  }

  DwlrData copyWith({
    String? id,
    String? stateName,
    String? districtName,
    String? tahsilName,
    String? blockName,
    String? siteName,
    String? siteType,
    String? siteSubType,
    String? aquiferType,
    double? depth,
    DateTime? wlsDate,
    double? waterLevel,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? wellType,
    Map<String, dynamic>? additionalData,
  }) {
    return DwlrData(
      id: id ?? this.id,
      stateName: stateName ?? this.stateName,
      districtName: districtName ?? this.districtName,
      tahsilName: tahsilName ?? this.tahsilName,
      blockName: blockName ?? this.blockName,
      siteName: siteName ?? this.siteName,
      siteType: siteType ?? this.siteType,
      siteSubType: siteSubType ?? this.siteSubType,
      aquiferType: aquiferType ?? this.aquiferType,
      depth: depth ?? this.depth,
      wlsDate: wlsDate ?? this.wlsDate,
      waterLevel: waterLevel ?? this.waterLevel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      wellType: wellType ?? this.wellType,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'DwlrData(id: $id, location: $location, waterLevel: $waterLevel, date: $wlsDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DwlrData && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}