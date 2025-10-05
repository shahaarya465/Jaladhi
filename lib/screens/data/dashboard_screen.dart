import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dwlr_provider.dart';
import '../../models/dwlr_data.dart';
import '../filter/hierarchical_filter_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load CSV data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DwlrProvider>();
      // Try to load CSV data first, then fallback to real-time data
      provider.loadCsvData();
      // Start auto-refresh every 5 minutes for real-time updates
      provider.startRealtimeUpdates();
    });
  }

  @override
  void dispose() {
    // Stop real-time updates when screen is disposed
    context.read<DwlrProvider>().stopRealtimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jaladhi Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HierarchicalFilterScreen(),
                ),
              );
            },
            tooltip: 'Filter by Location',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.data_usage),
            onSelected: (value) {
              final provider = context.read<DwlrProvider>();
              switch (value) {
                case 'csv':
                  provider.loadCsvData();
                  break;
                case 'api':
                  provider.loadRealtimeData();
                  break;
                case 'sample':
                  provider.loadSampleData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.file_present),
                    SizedBox(width: 8),
                    Text('Load CSV Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'api',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download),
                    SizedBox(width: 8),
                    Text('Load API Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sample',
                child: Row(
                  children: [
                    Icon(Icons.science),
                    SizedBox(width: 8),
                    Text('Load Sample Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DwlrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadSampleData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(provider),
                const SizedBox(height: 24),
                _buildDataList(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<DwlrProvider>().loadCsvData();
        },
        tooltip: 'Refresh CSV Data',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSummaryCards(DwlrProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Stations',
                provider.dwlrDataList.length.toString(),
                Icons.location_on,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Water Level',
                '${provider.getAverageWaterLevel().toStringAsFixed(1)} m',
                Icons.water_drop,
                Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Min Level',
                '${provider.getMinWaterLevel().toStringAsFixed(1)} m',
                Icons.arrow_downward,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Max Level',
                '${provider.getMaxWaterLevel().toStringAsFixed(1)} m',
                Icons.arrow_upward,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList(DwlrProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Data',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (provider.dwlrDataList.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No data available'),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.dwlrDataList.length,
            itemBuilder: (context, index) {
              final data = provider.dwlrDataList[index];
              return _buildDataCard(data, provider);
            },
          ),
      ],
    );
  }

  Widget _buildDataCard(DwlrData data, DwlrProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getWaterLevelColor(data.waterLevel),
          child: Icon(
            Icons.water_drop,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          data.location,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Level: ${data.waterLevel.toStringAsFixed(1)} m'),
            Text('Well Type: ${data.wellType}'),
            Text('Last Updated: ${_formatDateTime(data.timestamp)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          provider.setSelectedData(data);
          _showDataDetails(context, data);
        },
      ),
    );
  }

  Color _getWaterLevelColor(double waterLevel) {
    if (waterLevel > 15) return Colors.green;
    if (waterLevel > 10) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDataDetails(BuildContext context, DwlrData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.location),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', data.id),
            _buildDetailRow('Water Level', '${data.waterLevel} m'),
            _buildDetailRow('Well Type', data.wellType),
            _buildDetailRow('Depth', '${data.depth} m'),
            _buildDetailRow('Aquifer Type', data.aquiferType),
            _buildDetailRow('Coordinates', '${data.latitude.toStringAsFixed(4)}, ${data.longitude.toStringAsFixed(4)}'),
            _buildDetailRow('Last Updated', data.timestamp.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}