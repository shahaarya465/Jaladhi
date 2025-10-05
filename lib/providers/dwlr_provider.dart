import 'package:flutter/foundation.dart';
import '../models/dwlr_data.dart';
import '../models/location_hierarchy.dart';
import '../services/dwlr_api_service.dart';
import '../services/csv_data_service.dart';
import 'dart:async';

class DwlrProvider extends ChangeNotifier {
  List<DwlrData> _allDwlrData = [];
  List<DwlrData> _filteredDwlrDataList = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DwlrData? _selectedData;
  Timer? _realtimeTimer;
  FilterState _filterState = FilterState();
  
  final DwlrApiService _apiService = DwlrApiService();

  // Getters
  List<DwlrData> get dwlrDataList => List.unmodifiable(_filteredDwlrDataList);
  List<DwlrData> get allDwlrData => List.unmodifiable(_allDwlrData);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DwlrData? get selectedData => _selectedData;
  FilterState get filterState => _filterState;

  // Methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setSelectedData(DwlrData? data) {
    _selectedData = data;
    notifyListeners();
  }

  void addDwlrData(DwlrData data) {
    _allDwlrData.add(data);
    _applyFilters();
    notifyListeners();
  }

  void addAllDwlrData(List<DwlrData> dataList) {
    _allDwlrData.addAll(dataList);
    _applyFilters();
    notifyListeners();
  }

  void updateDwlrData(DwlrData updatedData) {
    final index = _allDwlrData.indexWhere((data) => data.id == updatedData.id);
    if (index != -1) {
      _allDwlrData[index] = updatedData;
      _applyFilters();
      notifyListeners();
    }
  }

  void removeDwlrData(String id) {
    _allDwlrData.removeWhere((data) => data.id == id);
    if (_selectedData?.id == id) {
      _selectedData = null;
    }
    _applyFilters();
    notifyListeners();
  }

  void clearAllData() {
    _allDwlrData.clear();
    _filteredDwlrDataList.clear();
    _selectedData = null;
    _filterState = FilterState();
    notifyListeners();
  }

  // Hierarchical filtering methods
  void _applyFilters() {
    _filteredDwlrDataList = _allDwlrData.where((data) {
      if (_filterState.selectedState != null && 
          data.stateName != _filterState.selectedState) {
        return false;
      }
      if (_filterState.selectedDistrict != null && 
          data.districtName != _filterState.selectedDistrict) {
        return false;
      }
      if (_filterState.selectedTahsil != null && 
          data.tahsilName != _filterState.selectedTahsil) {
        return false;
      }
      if (_filterState.selectedBlock != null && 
          data.blockName != _filterState.selectedBlock) {
        return false;
      }
      return true;
    }).toList();
  }

  void setStateFilter(String? stateName) {
    _filterState = _filterState.copyWith(
      selectedState: stateName,
      clearDistrict: true,
      clearTahsil: true,
      clearBlock: true,
    );
    _applyFilters();
    notifyListeners();
  }

  void setDistrictFilter(String? districtName) {
    _filterState = _filterState.copyWith(
      selectedDistrict: districtName,
      clearTahsil: true,
      clearBlock: true,
    );
    _applyFilters();
    notifyListeners();
  }

  void setTahsilFilter(String? tahsilName) {
    _filterState = _filterState.copyWith(
      selectedTahsil: tahsilName,
      clearBlock: true,
    );
    _applyFilters();
    notifyListeners();
  }

  void setBlockFilter(String? blockName) {
    _filterState = _filterState.copyWith(selectedBlock: blockName);
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterState = FilterState();
    _applyFilters();
    notifyListeners();
  }

  // Get unique values for dropdowns
  List<String> getAvailableStates() {
    return _allDwlrData
        .map((data) => data.stateName)
        .where((state) => state.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAvailableDistricts() {
    return _allDwlrData
        .where((data) => _filterState.selectedState == null || 
                        data.stateName == _filterState.selectedState)
        .map((data) => data.districtName)
        .where((district) => district.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAvailableTahsils() {
    return _allDwlrData
        .where((data) => 
            (_filterState.selectedState == null || 
             data.stateName == _filterState.selectedState) &&
            (_filterState.selectedDistrict == null || 
             data.districtName == _filterState.selectedDistrict))
        .map((data) => data.tahsilName)
        .where((tahsil) => tahsil.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAvailableBlocks() {
    return _allDwlrData
        .where((data) => 
            (_filterState.selectedState == null || 
             data.stateName == _filterState.selectedState) &&
            (_filterState.selectedDistrict == null || 
             data.districtName == _filterState.selectedDistrict) &&
            (_filterState.selectedTahsil == null || 
             data.tahsilName == _filterState.selectedTahsil))
        .map((data) => data.blockName)
        .where((block) => block.isNotEmpty)
        .toSet()
        .toList()
        ..sort();
  }

  // Filter methods
  List<DwlrData> getDataByLocation(String location) {
    return _filteredDwlrDataList.where((data) => 
      data.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  List<DwlrData> getDataByWellType(String wellType) {
    return _filteredDwlrDataList.where((data) => 
      data.wellType.toLowerCase() == wellType.toLowerCase()
    ).toList();
  }

  List<DwlrData> getDataByDateRange(DateTime startDate, DateTime endDate) {
    return _filteredDwlrDataList.where((data) => 
      data.timestamp.isAfter(startDate) && data.timestamp.isBefore(endDate)
    ).toList();
  }

  // Statistics methods
  double getAverageWaterLevel() {
    if (_filteredDwlrDataList.isEmpty) return 0.0;
    final sum = _filteredDwlrDataList.fold<double>(0.0, (sum, data) => sum + data.waterLevel);
    return sum / _filteredDwlrDataList.length;
  }

  double getMinWaterLevel() {
    if (_filteredDwlrDataList.isEmpty) return 0.0;
    return _filteredDwlrDataList.map((data) => data.waterLevel).reduce((a, b) => a < b ? a : b);
  }

  double getMaxWaterLevel() {
    if (_filteredDwlrDataList.isEmpty) return 0.0;
    return _filteredDwlrDataList.map((data) => data.waterLevel).reduce((a, b) => a > b ? a : b);
  }

  // Sample data for testing
  void loadSampleData() {
    final sampleData = [
      DwlrData(
        id: '1',
        stateName: 'Delhi',
        districtName: 'New Delhi',
        tahsilName: 'Central Delhi',
        blockName: 'Connaught Place',
        siteName: 'Delhi CGWB Station',
        siteType: 'Bore Well',
        siteSubType: 'Monitoring',
        aquiferType: 'Alluvial',
        depth: 50.0,
        wlsDate: DateTime.now().subtract(const Duration(hours: 1)),
        waterLevel: 15.5,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        wellType: 'Bore Well',
      ),
      DwlrData(
        id: '2',
        stateName: 'Maharashtra',
        districtName: 'Mumbai',
        tahsilName: 'Mumbai City',
        blockName: 'Fort',
        siteName: 'Mumbai CGWB Station',
        siteType: 'Open Well',
        siteSubType: 'Monitoring',
        aquiferType: 'Basaltic',
        depth: 40.0,
        wlsDate: DateTime.now().subtract(const Duration(hours: 2)),
        waterLevel: 12.3,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        wellType: 'Open Well',
      ),
      DwlrData(
        id: '3',
        stateName: 'Tamil Nadu',
        districtName: 'Chennai',
        tahsilName: 'Chennai North',
        blockName: 'Egmore',
        siteName: 'Chennai CGWB Station',
        siteType: 'Tube Well',
        siteSubType: 'Monitoring',
        aquiferType: 'Sedimentary',
        depth: 60.0,
        wlsDate: DateTime.now().subtract(const Duration(hours: 3)),
        waterLevel: 8.7,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        wellType: 'Tube Well',
      ),
    ];
    
    _allDwlrData = sampleData;
    _applyFilters();
    notifyListeners();
  }

  // Real-time data methods
  
  /// Load real-time DWLR data from API
  Future<void> loadRealtimeData() async {
    setLoading(true);
    clearError();
    
    try {
      // Try to load from real API first, fallback to mock data
      final data = await _apiService.getRealtimeData();
      _allDwlrData = data;
      _applyFilters();
      notifyListeners();
    } catch (e) {
      // If real API fails, use mock data for demo
      debugPrint('Real API failed, using mock data: $e');
      try {
        final mockData = await MockDwlrApiService.getMockRealtimeData();
        _allDwlrData = mockData;
        _applyFilters();
        notifyListeners();
      } catch (mockError) {
        setError('Failed to load data: $mockError');
      }
    } finally {
      setLoading(false);
    }
  }

  /// Start auto-refresh for real-time updates
  void startRealtimeUpdates({Duration interval = const Duration(minutes: 5)}) {
    stopRealtimeUpdates(); // Stop any existing timer
    
    _realtimeTimer = Timer.periodic(interval, (timer) async {
      if (!_isLoading) {
        await loadRealtimeData();
      }
    });
  }

  /// Stop auto-refresh
  void stopRealtimeUpdates() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
  }

  /// Load data for a specific station
  Future<void> loadStationData(String stationId) async {
    setLoading(true);
    clearError();
    
    try {
      final data = await _apiService.getStationData(stationId);
      setSelectedData(data);
    } catch (e) {
      setError('Failed to load station data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load historical data for analysis
  Future<List<DwlrData>> loadHistoricalData(
    String stationId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      return await _apiService.getHistoricalData(stationId, startDate, endDate);
    } catch (e) {
      setError('Failed to load historical data: $e');
      return [];
    }
  }

  /// Load DWLR data from CSV file
  Future<void> loadCsvData() async {
    setLoading(true);
    clearError();
    
    try {
      final data = await CsvDataService.loadFromCsv();
      _allDwlrData = data;
      _applyFilters();
      notifyListeners();
    } catch (e) {
      setError('Failed to load CSV data: $e');
      // Fallback to sample data
      loadSampleData();
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    stopRealtimeUpdates();
    super.dispose();
  }
}