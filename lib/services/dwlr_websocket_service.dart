import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/dwlr_data.dart';

class DwlrWebSocketService {
  WebSocket? _socket;
  StreamController<List<DwlrData>>? _dataController;
  Timer? _heartbeatTimer;
  
  Stream<List<DwlrData>>? get dataStream => _dataController?.stream;
  
  /// Connect to real-time DWLR WebSocket
  Future<void> connect(String wsUrl) async {
    try {
      _socket = await WebSocket.connect(wsUrl);
      _dataController = StreamController<List<DwlrData>>.broadcast();
      
      _socket!.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
      
      // Start heartbeat every 30 seconds to keep connection alive
      _startHeartbeat();
      
      debugPrint('Connected to DWLR WebSocket: $wsUrl');
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
      throw Exception('WebSocket connection failed: $e');
    }
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      
      if (data['type'] == 'dwlr_data') {
        final List<dynamic> stationsData = data['data'];
        final dwlrList = stationsData
            .map((json) => DwlrData.fromJson(json))
            .toList();
        
        _dataController?.add(dwlrList);
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }
  
  /// Handle WebSocket errors
  void _handleError(error) {
    debugPrint('WebSocket error: $error');
    _dataController?.addError(error);
  }
  
  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    _cleanup();
  }
  
  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket?.readyState == WebSocket.open) {
        _socket?.add(json.encode({'type': 'ping'}));
      }
    });
  }
  
  /// Subscribe to specific stations
  void subscribeToStations(List<String> stationIds) {
    if (_socket?.readyState == WebSocket.open) {
      _socket?.add(json.encode({
        'type': 'subscribe',
        'stations': stationIds,
      }));
    }
  }
  
  /// Disconnect and cleanup
  void disconnect() {
    _cleanup();
    _socket?.close();
  }
  
  void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _dataController?.close();
    _dataController = null;
  }
}

/// Mock WebSocket Service for Testing
class MockDwlrWebSocketService {
  StreamController<List<DwlrData>>? _dataController;
  Timer? _mockTimer;
  
  Stream<List<DwlrData>>? get dataStream => _dataController?.stream;
  
  /// Start mock real-time data stream
  void startMockStream() {
    _dataController = StreamController<List<DwlrData>>.broadcast();
    
    // Send mock data every 10 seconds
    _mockTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _generateMockData();
    });
    
    // Send initial data
    _generateMockData();
  }
  
  void _generateMockData() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch;
    
    final mockData = [
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
        waterLevel: 12.5 + ((random % 200) - 100) / 100, // ±1m variation
        wlsDate: now,
        wellType: 'Bore Well',
        depth: 45.0,
        aquiferType: 'Alluvial',
        additionalData: {
          'temperature': 28.5 + ((random % 50) - 25) / 10,
          'ph': 7.2 + ((random % 20) - 10) / 10,
          'conductivity': 850 + (random % 100),
          'batteryVoltage': 12.5 + ((random % 10) - 5) / 10,
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
        waterLevel: 8.3 + ((random % 100) - 50) / 100,
        wlsDate: now,
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
        waterLevel: 15.7 + ((random % 80) - 40) / 100,
        wlsDate: now,
        wellType: 'Tube Well',
        depth: 60.0,
        aquiferType: 'Sedimentary',
      ),
    ];
    
    _dataController?.add(mockData);
  }
  
  void stopMockStream() {
    _mockTimer?.cancel();
    _mockTimer = null;
    _dataController?.close();
    _dataController = null;
  }
}