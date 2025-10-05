# 📊 CSV File Integration Guide

## 🎯 **Your CSV File is Ready!**

Your Flutter app now supports loading DWLR data from CSV files!

### 📁 **Where to Put Your CSV File:**

```
d:\SIH\jaladhi\assets\data\dwlr_stations.csv
```

**✅ I've already created a sample file there for you!**

---

## 📋 **CSV File Format:**

Your CSV file should have these columns (in any order):

### **Required Columns:**
- `id` or `station_id` or `dwlr_id` - Unique identifier
- `location` or `station_name` or `place` - Station location name
- `latitude` or `lat` - Latitude coordinate
- `longitude` or `lng` or `lon` - Longitude coordinate  
- `water_level` or `level` or `depth_to_water` - Water level in meters

### **Optional Columns:**
- `timestamp` or `date` or `last_updated` - Date/time of reading
- `well_type` or `type` - Type of well (Bore Well, Open Well, etc.)
- `depth` or `total_depth` - Total depth of well
- `aquifer_type` or `aquifer` - Type of aquifer
- `temperature` - Water temperature
- `ph` - pH level
- `conductivity` - Electrical conductivity
- Any other columns will be stored as additional data

---

## 📄 **Sample CSV Content:**

```csv
id,location,latitude,longitude,water_level,timestamp,well_type,depth,aquifer_type,temperature,ph,conductivity
DWLR001,Ahmedabad CGWB Station,23.0225,72.5714,12.5,2025-09-30T10:30:00Z,Bore Well,45.0,Alluvial,28.5,7.2,850
DWLR002,Rajkot CGWB Station,22.3039,70.8022,8.3,2025-09-30T09:15:00Z,Open Well,35.0,Basaltic,29.1,6.8,920
DWLR003,Gandhinagar CGWB Station,23.2156,72.6369,15.7,2025-09-30T11:45:00Z,Tube Well,60.0,Sedimentary,27.8,7.5,780
```

---

## 🚀 **How to Use:**

### **Method 1: App Menu**
1. **Run the app** (`flutter run -d chrome`)
2. **Click the data icon** (📊) in the app bar
3. **Select "Load CSV Data"**

### **Method 2: Refresh Button**
- **Click the blue refresh button** (now loads CSV by default)

### **Method 3: Auto-load**
- **CSV data loads automatically** when app starts

---

## 🔄 **Supported Date Formats:**

The app can parse these date formats:
- `2025-09-30T10:30:00Z` (ISO 8601)
- `2025-09-30 10:30:00`
- `30/09/2025` (DD/MM/YYYY)
- `09/30/2025` (MM/DD/YYYY)

---

## 📁 **File Structure:**

```
d:\SIH\jaladhi\
├── assets\
│   └── data\
│       └── dwlr_stations.csv  ← Your CSV file goes here
├── lib\
│   ├── services\
│   │   └── csv_data_service.dart  ← CSV parsing logic
│   └── providers\
│       └── dwlr_provider.dart  ← Data management
└── pubspec.yaml  ← Assets configuration
```

---

## 🎛️ **App Features:**

### **Data Source Menu:**
The app now has 3 data sources:
1. **📄 CSV Data** - Your local file
2. **☁️ API Data** - Real-time from internet
3. **🧪 Sample Data** - Test data

### **Auto-Detection:**
- App automatically detects your CSV column names
- Handles missing columns gracefully
- Shows informative error messages

---

## 🛠️ **To Use Your Real CSV File:**

### **Step 1: Replace Sample File**
1. Delete: `d:\SIH\jaladhi\assets\data\dwlr_stations.csv`
2. Copy your CSV file to the same location
3. Keep the same filename OR update the code

### **Step 2: Update File Path (if needed)**
If your file has a different name, update this line in `csv_data_service.dart`:
```dart
static const String _csvFilePath = 'assets/data/YOUR_FILE_NAME.csv';
```

### **Step 3: Test the App**
```bash
flutter run -d chrome
```

---

## 🎯 **Error Handling:**

The app handles these issues gracefully:
- **Missing columns** - Uses default values
- **Invalid data** - Skips bad rows, continues with good ones
- **File not found** - Falls back to sample data
- **Empty file** - Shows error message

---

## 📊 **What You'll See:**

After loading your CSV:
1. **Summary cards** with total stations, avg/min/max water levels
2. **Station list** with all your DWLR data
3. **Detailed view** when you tap any station
4. **Real-time updates** (refreshes CSV every 5 minutes)

---

## 🎉 **Ready to Use!**

**Your app is now configured to read CSV files!**

Just:
1. **Put your CSV file** in `assets/data/dwlr_stations.csv`
2. **Run the app**: `flutter run -d chrome`
3. **Watch your data** load automatically!

**The sample file I created shows the exact format your real CSV should follow.** 📈