# Real-time DWLR Data Integration Guide

## 🌊 Current Implementation

Your app now supports **multiple ways** to get real-time groundwater data:

### 1. 🔄 **Periodic API Calls** (Currently Active)
- **Auto-refresh every 5 minutes**
- **Manual refresh** via floating action button
- **Fallback to mock data** if real APIs are unavailable

### 2. 🌐 **WebSocket Streaming** (Available)
- **True real-time updates** as data changes
- **Mock service** for testing included

### 3. 📊 **Government API Integration** (Ready)
- **Template for real APIs** in `DwlrApiService`
- **Examples for major Indian water departments**

---

## 🚀 **How to Connect Real Data Sources**

### Option A: Government APIs

**1. Central Ground Water Board (CGWB)**
```dart
// Replace in dwlr_api_service.dart
static const String baseUrl = 'https://cgwb.gov.in/api/v1';
```

**2. State Water Resource Departments**
```dart
// Gujarat
static const String baseUrl = 'https://guj-nwrws.gujarat.gov.in/api';

// Rajasthan  
static const String baseUrl = 'https://water.rajasthan.gov.in/api';
```

**3. India-WRIS (Water Resources Information System)**
```dart
static const String baseUrl = 'https://indiawris.gov.in/wris/api';
```

### Option B: WebSocket for Real-time Streaming

```dart
// In your provider, add:
final wsService = DwlrWebSocketService();
await wsService.connect('wss://your-dwlr-websocket.gov.in');

wsService.dataStream?.listen((data) {
  _dwlrDataList = data;
  notifyListeners();
});
```

### Option C: IoT Sensor Integration

**For direct sensor data:**
```dart
// Add MQTT or other IoT protocols
import 'package:mqtt_client/mqtt_client.dart';

class IoTDwlrService {
  // Connect to IoT sensors directly
  // Parse telemetry data
  // Convert to DwlrData format
}
```

---

## 📱 **Current App Features**

### ✅ **What's Working Now:**
- **Dashboard with summary cards**
- **Real-time data simulation** (mock data changes every 10 seconds)
- **Auto-refresh every 5 minutes**
- **Manual refresh button**
- **Station details view**
- **Error handling and loading states**

### 🔄 **Real-time Updates:**
- Data refreshes automatically
- Shows current timestamp
- Simulates water level changes
- Includes additional sensor data (temperature, pH, conductivity)

---

## 🛠 **To Use Real Government APIs:**

### Step 1: Get API Access
1. **Contact respective departments**:
   - CGWB: [cgwb.gov.in](https://cgwb.gov.in)
   - State Water Departments
   - India-WRIS Portal

2. **Obtain API keys/credentials**

3. **Get API documentation** with:
   - Endpoint URLs
   - Request/response formats
   - Authentication methods

### Step 2: Update API Service
```dart
// In dwlr_api_service.dart, update:
static const String baseUrl = 'YOUR_REAL_API_URL';

Map<String, String> get _headers => {
  'Authorization': 'Bearer YOUR_API_KEY',
  'Content-Type': 'application/json',
};
```

### Step 3: Parse Real Response Format
```dart
// Update DwlrData.fromJson() to match real API response:
factory DwlrData.fromJson(Map<String, dynamic> json) {
  return DwlrData(
    id: json['station_id'],           // Adjust field names
    location: json['station_name'],   // to match real API
    waterLevel: json['water_level'].toDouble(),
    // ... other fields
  );
}
```

---

## 🧪 **Testing Current Setup:**

### Run the App:
```bash
flutter run -d chrome
```

### What You'll See:
1. **Dashboard loads with 3 mock stations**
2. **Data auto-refreshes every 5 minutes**
3. **Water levels change slightly each refresh** (simulating real sensors)
4. **Click refresh button** for manual updates
5. **Tap stations** to see detailed information

### Check Real-time Updates:
- Watch the timestamps update
- Notice water level variations
- See additional sensor data (temperature, pH)

---

## 📊 **Sample Data Structure**

Current mock data includes:
```json
{
  "id": "DWLR001",
  "location": "Ahmedabad DWLR Station", 
  "latitude": 23.0225,
  "longitude": 72.5714,
  "waterLevel": 12.5,
  "timestamp": "2025-09-30T10:30:00Z",
  "wellType": "Bore Well",
  "depth": 45.0,
  "aquiferType": "Alluvial",
  "additionalData": {
    "temperature": 28.5,
    "ph": 7.2,
    "conductivity": 850,
    "batteryVoltage": 12.5
  }
}
```

---

## 🎯 **Next Steps:**

1. **Test current app** to see real-time simulation
2. **Provide actual API details** if you have them
3. **Share UI design** for custom implementation
4. **Choose preferred update frequency** (current: 5 minutes)
5. **Add authentication** if required by APIs

**The app is ready for real data - just need the actual API endpoints! 🚀**