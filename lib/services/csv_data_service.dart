import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../models/dwlr_data.dart';

class CsvDataService {
  static const String _csvFilePath = 'assets/data/SIH.csv';
  
  /// Load DWLR data from CSV file
  static Future<List<DwlrData>> loadFromCsv({String? customPath}) async {
    try {
      final csvPath = customPath ?? _csvFilePath;
      final csvString = await rootBundle.loadString(csvPath);
      
      // Parse CSV
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
      
      if (csvTable.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      // Get headers (first row)
      final headers = csvTable.first.map((e) => e.toString().toLowerCase()).toList();
      
      // Convert rows to DwlrData objects
      final dataList = <DwlrData>[];
      
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        try {
          final dwlrData = _parseRowToDwlrData(headers, row);
          dataList.add(dwlrData);
        } catch (e) {
          debugPrint('Error parsing row $i: $e');
          // Continue with next row
        }
      }
      
      return dataList;
    } catch (e) {
      throw Exception('Failed to load CSV data: $e');
    }
  }
  
  /// Parse a CSV row to DwlrData object
  static DwlrData _parseRowToDwlrData(List<String> headers, List<dynamic> row) {
    // Helper function to get value from row by header name
    String getValue(String headerName) {
      final index = headers.indexOf(headerName.toLowerCase());
      if (index >= 0 && index < row.length) {
        return row[index]?.toString() ?? '';
      }
      return '';
    }
    
    double getDoubleValue(String headerName, {double defaultValue = 0.0}) {
      final value = getValue(headerName);
      return double.tryParse(value) ?? defaultValue;
    }
    
    DateTime getDateTimeValue(String headerName) {
      final value = getValue(headerName);
      if (value.isEmpty) return DateTime.now();
      
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
    
    // Map SIH CSV column names to our data model
    final id = getValue('site_id');
    final stateName = getValue('state_name');
    final districtName = getValue('district_name');
    final tahsilName = getValue('tahsil_name');
    final blockName = getValue('block_name');
    final siteName = getValue('site_name');
    final siteType = getValue('site_type');
    final siteSubType = getValue('site_sub_type');
    final aquiferType = getValue('aquifer_type');
    final depth = getDoubleValue('depth');
    final wlsDate = getDateTimeValue('wls_date');
    final waterLevel = getDoubleValue('wls_wtr_leve');
    
    // Additional data from other columns
    final additionalData = <String, dynamic>{};
    
    // Add any extra columns as additional data
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      if (i < row.length && 
          !['site_id', 'state_name', 'district_name', 'tahsil_name', 'block_name', 
            'site_name', 'site_type', 'site_sub_type', 'aquifer_type', 'depth', 
            'wls_date', 'wls_wtr_leve'].contains(header)) {
        additionalData[header] = row[i];
      }
    }
    
    return DwlrData(
      id: id.isEmpty ? 'SIH_${DateTime.now().millisecondsSinceEpoch}' : id,
      stateName: stateName,
      districtName: districtName,
      tahsilName: tahsilName,
      blockName: blockName,
      siteName: siteName,
      siteType: siteType,
      siteSubType: siteSubType,
      aquiferType: aquiferType,
      depth: depth,
      wlsDate: wlsDate,
      waterLevel: waterLevel,
      additionalData: additionalData,
    );
  }
  
  static int _monthNameToNumber(String monthName) {
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    return months[monthName.toLowerCase().substring(0, 3)] ?? 1;
  }
  
  /// Generate sample CSV file content for testing
  static String generateSampleCsv() {
    return '''id,location,latitude,longitude,water_level,timestamp,well_type,depth,aquifer_type,temperature,ph,conductivity
DWLR001,Ahmedabad CGWB Station,23.0225,72.5714,12.5,2025-09-30T10:30:00Z,Bore Well,45.0,Alluvial,28.5,7.2,850
DWLR002,Rajkot CGWB Station,22.3039,70.8022,8.3,2025-09-30T09:15:00Z,Open Well,35.0,Basaltic,29.1,6.8,920
DWLR003,Gandhinagar CGWB Station,23.2156,72.6369,15.7,2025-09-30T11:45:00Z,Tube Well,60.0,Sedimentary,27.8,7.5,780
DWLR004,Vadodara CGWB Station,22.3072,73.1812,11.2,2025-09-30T08:30:00Z,Bore Well,50.0,Alluvial,30.2,7.0,890
DWLR005,Surat CGWB Station,21.1702,72.8311,6.8,2025-09-30T12:00:00Z,Open Well,28.0,Coastal,31.5,6.5,1200''';
  }
  
  /// Save sample CSV to assets folder (for development)
  static void printSampleCsvInstructions() {
    debugPrint('=== Sample CSV Format ===');
    debugPrint('Create a file: assets/data/dwlr_stations.csv');
    debugPrint('With content:');
    debugPrint(generateSampleCsv());
    debugPrint('========================');
  }
}