import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dwlr_provider.dart';

class HierarchicalFilterScreen extends StatelessWidget {
  const HierarchicalFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter by Location'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              context.read<DwlrProvider>().clearFilters();
            },
            tooltip: 'Clear All Filters',
          ),
        ],
      ),
      body: Consumer<DwlrProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterInfo(provider),
                const SizedBox(height: 24),
                _buildStateDropdown(provider),
                const SizedBox(height: 16),
                _buildDistrictDropdown(provider),
                const SizedBox(height: 16),
                _buildTahsilDropdown(provider),
                const SizedBox(height: 16),
                _buildBlockDropdown(provider),
                const SizedBox(height: 24),
                _buildResultsSection(provider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterInfo(DwlrProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Current Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              provider.filterState.hasAnySelection
                  ? provider.filterState.toString()
                  : 'No filters applied - showing all data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${provider.dwlrDataList.length} of ${provider.allDwlrData.length} stations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateDropdown(DwlrProvider provider) {
    final states = provider.getAvailableStates();
    
    return _buildDropdownCard(
      'Select State',
      Icons.map,
      provider.filterState.selectedState,
      states,
      (value) => provider.setStateFilter(value),
      enabled: states.isNotEmpty,
    );
  }

  Widget _buildDistrictDropdown(DwlrProvider provider) {
    final districts = provider.getAvailableDistricts();
    
    return _buildDropdownCard(
      'Select District',
      Icons.location_city,
      provider.filterState.selectedDistrict,
      districts,
      (value) => provider.setDistrictFilter(value),
      enabled: districts.isNotEmpty,
    );
  }

  Widget _buildTahsilDropdown(DwlrProvider provider) {
    final tahsils = provider.getAvailableTahsils();
    
    return _buildDropdownCard(
      'Select Tahsil',
      Icons.domain,
      provider.filterState.selectedTahsil,
      tahsils,
      (value) => provider.setTahsilFilter(value),
      enabled: tahsils.isNotEmpty,
    );
  }

  Widget _buildBlockDropdown(DwlrProvider provider) {
    final blocks = provider.getAvailableBlocks();
    
    return _buildDropdownCard(
      'Select Block',
      Icons.apartment,
      provider.filterState.selectedBlock,
      blocks,
      (value) => provider.setBlockFilter(value),
      enabled: blocks.isNotEmpty,
    );
  }

  Widget _buildDropdownCard(
    String title,
    IconData icon,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
    {bool enabled = true}
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: enabled ? Colors.blue[600] : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.blue[600] : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                hintText: enabled ? 'Choose $title' : 'No options available',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: enabled
                  ? [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...options.map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          )),
                    ]
                  : [],
              onChanged: enabled ? onChanged : null,
            ),
            if (options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${options.length} options available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(DwlrProvider provider, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Filtered Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('View Dashboard'),
                ),
                ElevatedButton.icon(
                  onPressed: provider.dwlrDataList.isNotEmpty
                      ? () {
                          _showDetailedResults(context, provider);
                        }
                      : null,
                  icon: const Icon(Icons.list),
                  label: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedResults(BuildContext context, DwlrProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Filtered Station Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provider.dwlrDataList.length,
                  itemBuilder: (context, index) {
                    final data = provider.dwlrDataList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(data.siteName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${data.blockName}, ${data.districtName}'),
                            Text('Water Level: ${data.waterLevel.toStringAsFixed(1)} m'),
                            Text('Site Type: ${data.siteType}'),
                          ],
                        ),
                        trailing: Text(
                          '${data.depth.toStringAsFixed(1)} m\nDepth',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          provider.setSelectedData(data);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}