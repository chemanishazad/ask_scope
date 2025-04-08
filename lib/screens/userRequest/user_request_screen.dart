import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/userRequest/filterUser.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRequestScreen extends ConsumerStatefulWidget {
  const UserRequestScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserRequestScreenState();
}

class _UserRequestScreenState extends ConsumerState<UserRequestScreen> {
  String assignUser = '';
  String currentTl = '';
  List<dynamic> userRequests = [];
  List<dynamic> filteredRequests = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginData();
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    setState(() => isLoading = true);

    final response = await ref.read(tlScopeProvider({
      'assign_users': assignUser,
      'current_tl': currentTl,
      'ref_id': filters['ref_id'] ?? '',
      'user_id': filters['user_id'] ?? '',
      'service_name': filters['service_name'] ?? '',
      'status': filters['status'] ?? '',
      'ptp': filters['ptp'] ?? '',
      'feasability_status': filters['feasability_status'] ?? '',
      'tags': filters['tags'] ?? '',
      'start_date': filters['start_date'] ?? '',
      'end_date': filters['end_date'] ?? '',
    }).future);

    final data = response['allQuoteData'];
    setState(() {
      userRequests = data ?? [];
      filteredRequests = userRequests;
      isLoading = false;
    });
  }

  Future<void> loginData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    assignUser = prefs.getString('tl_users') ?? '';
    currentTl = prefs.getString('fld_email') ?? '';

    final response = await ref.read(tlScopeProvider({
      'assign_users': assignUser,
      'current_tl': currentTl,
      'start_date': '',
      'end_date': '',
      'feasability_status': '',
      'ptp': '',
      'ref_id': '',
      'user_id': '',
      'service_name': '',
      'status': '',
      'tags': '',
    }).future);

    final data = response['allQuoteData'];

    setState(() {
      userRequests = data ?? [];
      filteredRequests = userRequests;
      isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() => filteredRequests = userRequests);
      return;
    }

    final results = userRequests.where((item) {
      final client = (item['client_name'] ?? '').toLowerCase();
      final refId = (item['ref_id'] ?? '').toString().toLowerCase();
      return client.contains(query.toLowerCase()) ||
          refId.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredRequests = results);
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
          child: FilterUser(
            onFilterApplied: (filters) async {
              Navigator.pop(context);
              await applyFilters(filters);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        title: const Text("User Requests"),
        actions: [
          IconButton(
            onPressed: _showFilterModal,
            icon: const Icon(Icons.filter_alt_outlined, size: 20),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: filterSearchResults,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search by Client Name or Ref ID",
                      hintStyle: const TextStyle(fontSize: 11),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredRequests.isEmpty
                      ? const Center(child: Text("No requests found"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final item = filteredRequests[index];
                            final crmName =
                                "${item['fld_first_name'] ?? ''} ${item['fld_last_name'] ?? ''}";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: InkWell(
                                onTap: () {
                                  // print(item);
                                  Navigator.pushNamed(context, '/detailsQuery',
                                      arguments: {
                                        'refId': item['ref_id'],
                                        'quoteId': item['id'],
                                      });
                                },
                                child: Container(
                                  decoration: cardDecoration(context: context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left content (Ref ID info)
                                              Expanded(
                                                flex: 4,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(Icons.numbers,
                                                        size: 15),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            width: 100,
                                                            child: Text(
                                                              "Ref ID",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            item['ref_id']
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Lottie.asset(
                                                  'assets/json/right.json',
                                                  height: 20)
                                            ],
                                          ),
                                        ),
                                        _rowItem(Icons.person_outline, "Client",
                                            item['client_name']),
                                        _rowItem(Icons.supervisor_account,
                                            "CRM", crmName.trim()),
                                        _rowItem(Icons.design_services,
                                            "Service", item['service_name']),
                                        _rowItem(
                                            Icons.check_circle_outline,
                                            "Feasibility",
                                            item['feasability_status']),
                                        _rowItem(Icons.check_circle_outline,
                                            "Quote Status", item['status']),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _rowItem(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          SizedBox(
            width: 100,
            child: Text(
              "$title: ",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
