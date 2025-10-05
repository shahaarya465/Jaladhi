import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dwlr_data.dart';

class DwlrApiService {
  static const String baseUrl = 'https://your-dwlr-api.gov.in/api/v1';
  
  // Example API endpoints - replace with actual ones
  static const String _allStationsEndpoint = '$baseUrl/stations';
  static const String _realtimeDataEndpoint = '$baseUrl/realtime';
  static const String _historicalDataEndpoint = '$baseUrl/historical';

  // Headers for API authentication (if required)
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add API key if required: 'Authorization': 'Bearer YOUR_API_KEY',
  };

  /// Fetch all DWLR stations
  Future<List<DwlrData>> getAllStations() async {
    try {
      final response = await http.get(
        Uri.parse(_allStationsEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DwlrData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch real-time data for all stations
  Future<List<DwlrData>> getRealtimeData() async {
    try {
      final response = await http.get(
        Uri.parse(_realtimeDataEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DwlrData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch realtime data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch data for a specific station
  Future<DwlrData> getStationData(String stationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_realtimeDataEndpoint/$stationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DwlrData.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch station data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch historical data for a station
  Future<List<DwlrData>> getHistoricalData(
    String stationId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final queryParams = {
        'stationId': stationId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final uri = Uri.parse(_historicalDataEndpoint).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DwlrData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch historical data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

/// Real Government API Examples (You may need to use these):
class GovernmentDwlrApis {
  // 1. Central Ground Water Board (CGWB) - India
  static const String cgwbApi = 'https://cgwb.gov.in/api';
  
  // 2. State Water Resources Department APIs
  static const String gujaratWrdApi = 'https://guj-nwrws.gujarat.gov.in/api';
  static const String rajasthanWrdApi = 'https://water.rajasthan.gov.in/api';
  
  // 3. India-WRIS (Water Resources Information System)
  static const String indiaWrisApi = 'https://indiawris.gov.in/wris/api';
  
  // 4. National Informatics Centre (NIC) APIs
  static const String nicApi = 'https://nic.in/groundwater/api';

  /// Example: Fetch from CGWB API
  static Future<List<DwlrData>> fetchFromCgwb() async {
    // Implementation would depend on actual CGWB API structure
    try {
      final response = await http.get(
        Uri.parse('$cgwbApi/dwlr/realtime'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        // Parse according to CGWB API response format
        final data = json.decode(response.body);
        return _parseCgwbResponse(data);
      }
      throw Exception('CGWB API error');
    } catch (e) {
      throw Exception('Failed to fetch from CGWB: $e');
    }
  }

  static List<DwlrData> _parseCgwbResponse(dynamic data) {
    // This would need to be customized based on actual API response format
    // Each government API has different response structures
    return [];
  }
}

/// Mock API Service for Testing
class MockDwlrApiService {
  /// Simulates real-time data with random variations
  static Future<List<DwlrData>> getMockRealtimeData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final random = DateTime.now().millisecondsSinceEpoch;
    
    return [
      DwlrData(
        id: 'DWLR001',
        stateName: 'GUJARAT',
        districtName: 'AHMEDABAD',
        tahsilName: 'AHMEDABAD',
        blockName: 'AHMEDABAD CITY',
        siteName: 'Ahmedabad DWLR Station',
        siteType: 'DWLR',
        siteSubType: 'Auto',
        latitude: 23.0225,
        longitude: 72.5714,
        waterLevel: 12.5 + (random % 100) / 100, // Simulate real-time changes
        wlsDate: DateTime.now(),
        wellType: 'Bore Well',
        depth: 45.0,
        aquiferType: 'Alluvial',
        additionalData: {
          'temperature': 28.5,
          'ph': 7.2,
          'conductivity': 850,
        },
      ),
      DwlrData(
        id: 'DWLR002',
        stateName: 'GUJARAT',
        districtName: 'RAJKOT',
        tahsilName: 'RAJKOT',
        blockName: 'RAJKOT CITY',
        siteName: 'Rajkot DWLR Station',
        siteType: 'DWLR',
        siteSubType: 'Manual',
        latitude: 22.3039,
        longitude: 70.8022,
        waterLevel: 8.3 + (random % 50) / 100,
        wlsDate: DateTime.now(),
        wellType: 'Open Well',
        depth: 35.0,
        aquiferType: 'Basaltic',
      ),
      DwlrData(
        id: 'DWLR003',
        stateName: 'GUJARAT',
        districtName: 'GANDHINAGAR',
        tahsilName: 'GANDHINAGAR',
        blockName: 'GANDHINAGAR CITY',
        siteName: 'Gandhinagar DWLR Station',
        siteType: 'DWLR',
        siteSubType: 'Auto',
        latitude: 23.2156,
        longitude: 72.6369,
        waterLevel: 15.7 + (random % 80) / 100,
        wlsDate: DateTime.now(),
        wellType: 'Tube Well',
        depth: 60.0,
        aquiferType: 'Sedimentary',
      ),
    ];
  }
}