import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/scopeRequest/widget/scope_filter.dart';

class ScopeRequestScreen extends ConsumerStatefulWidget {
  const ScopeRequestScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScopeRequestScreenState();
}

class _ScopeRequestScreenState extends ConsumerState<ScopeRequestScreen> {
  List<dynamic> scopeData = [];
  List<dynamic> filteredData = [];
  bool isLoading = false;
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';
  String selectedFilter = 'All Quotes';

  @override
  void initState() {
    super.initState();
    applyFilters({});
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ScopeFilter(
            onFilterApplied: (filters) async {
              Navigator.pop(context);
              await applyFilters(filters);
            },
          ),
        );
      },
    );
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    setState(() => isLoading = true);
    final response = await ref.read(tlScopeRequestProvider({
      'ref_id': filters['ref_id'] ?? '',
      'scope_id': filters['scope_id'] ?? '',
      'search_keywords': filters['search_keywords'] ?? '',
      'service_name': filters['service_name'] ?? '',
      'subject_area': filters['subject_area'] ?? '',
      'feasability_status': filters['feasability_status'] ?? '',
      'userid': filters['userId'] ?? '',
      'ptp': filters['ptp'] ?? '',
      'callrecordingpending': filters['callrecordingpending'] ?? '',
      'start_date': filters['start_date'] ?? '',
      'end_date': filters['end_date'] ?? '',
      'status': filters['status'] ?? '',
      'tags': filters['tags'] ?? '',
    }).future);

    scopeData = response['allQuoteData'] ?? [];
    _filterAndPaginate();
    setState(() => isLoading = false);
  }

  void _filterAndPaginate() {
    filteredData = scopeData.where((item) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          item['ref_id']?.toLowerCase().contains(query) == true ||
              item['client_name']?.toLowerCase().contains(query) == true ||
              item['id']?.toLowerCase().contains(query) == true;

      final matchesFilter = selectedFilter == 'All Quotes' ||
          (selectedFilter == 'Pending at User' &&
              item['quote_status'] == 'Pending at User') ||
          (selectedFilter == 'Pending at Admin' &&
              item['quote_status'] == 'Pending at Admin');

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<dynamic> _getCurrentPageItems() {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredData.sublist(
        start, end > filteredData.length ? filteredData.length : end);
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1;
      _filterAndPaginate();
    });
  }

  void _goToPage(int page) {
    setState(() => currentPage = page);
  }

  void _changeItemsPerPage(int value) {
    setState(() {
      itemsPerPage = value;
      currentPage = 1;
      _filterAndPaginate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (filteredData.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        title: const Text("Scope Requests", style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            onPressed: _showFilterModal,
            icon: const Icon(Icons.filter_alt_outlined, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search by Quote ID, Ref ID, Name',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildTopTabButton('All Quotes'),
                _buildTopTabButton('Pending at User'),
                _buildTopTabButton('Pending at Admin'),
              ],
            ),
          ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filteredData.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No data found'),
                    ElevatedButton(
                      onPressed: () {
                        applyFilters({});
                      },
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _getCurrentPageItems().length,
                itemBuilder: (context, index) {
                  final item = _getCurrentPageItems()[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/scopeCard',
                            arguments: item['ref_id']);
                      },
                      child: Container(
                        decoration: cardDecoration(context: context),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTextWithStatus(
                                    label: 'Ref ID: ${item['ref_id']}',
                                    status: item['quote_status'] ?? '',
                                    icon: Icons.credit_card_outlined,
                                  ),
                                  _buildTextWithStatus(
                                    label: 'Quote ID: ${item['id']}',
                                    status: item['quote_status'] ?? '',
                                    icon: Icons.code_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Client and Service Details
                              _buildDetailRow(
                                label: 'Client:',
                                value: item['client_name'] ?? '-',
                                icon: Icons.person_outline,
                              ),
                              _buildDetailRow(
                                label: 'Service:',
                                value: item['service_name'] ?? '-',
                                icon: Icons.design_services_outlined,
                              ),
                              const SizedBox(height: 4),

                              // Status Section with Color Based on Status
                              _buildStatusRow(item['quote_status'] ?? '-'),

                              // Feasibility Status and Date
                              _buildDetailRow(
                                label: 'Feasibility Status:',
                                value: item['feasability_status'] ??
                                    'Not Available',
                                icon: Icons.hourglass_empty_outlined,
                              ),
                              _buildDetailRow(
                                label: 'Created On:',
                                value: DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(item['created_date'] ?? '0') *
                                            1000)
                                    .toLocal()
                                    .toString(),
                                icon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (!isLoading && filteredData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Show:', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: itemsPerPage,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        underline: Container(height: 1, color: Colors.grey),
                        onChanged: (value) {
                          if (value != null) _changeItemsPerPage(value);
                        },
                        items: [10, 20, 50, 100]
                            .map((value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentPage > 1
                            ? () => _goToPage(currentPage - 1)
                            : null,
                        icon: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color:
                              currentPage > 1 ? Colors.white : Colors.grey[600],
                        ),
                        label: const Text('Previous',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? Palette.themeColor
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Page $currentPage of $totalPages',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: currentPage < totalPages
                            ? () => _goToPage(currentPage + 1)
                            : null,
                        icon: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: currentPage < totalPages
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                        label:
                            const Text('Next', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage < totalPages
                              ? Palette.themeColor
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopTabButton(String label) {
    final isSelected = selectedFilter == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedFilter = label;
              currentPage = 1;
              _filterAndPaginate();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Palette.themeColor : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
      ),
    );
  }

  // Helper method to build Text with Status Color and Icon
  Widget _buildTextWithStatus({
    required String label,
    required String status,
    required IconData icon,
  }) {
    Color statusColor = _getStatusColor(status);

    return Row(
      children: [
        Icon(icon, size: 14, color: Palette.themeColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Palette.themeColor),
          const SizedBox(width: 6),
          SizedBox(
            width: 100,
            child: Text(
              '$label ',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    Color statusColor = _getStatusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 14, color: Palette.themeColor),
          const SizedBox(width: 6),
          const SizedBox(
            width: 100,
            child: Text(
              'Status: ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending at Admin':
        return Colors.orange;
      case 'Pending at User':
        return Colors.blue;
      case 'Feasability Completed':
        return Colors.green;
      case 'Feasability Completed and Admin Pending':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
