import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/components/custom_multiselect.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/static_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScopeFilter extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onFilterApplied;

  const ScopeFilter({super.key, required this.onFilterApplied});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ScopeFilterState();
}

class ScopeFilterState extends ConsumerState<ScopeFilter> {
  final TextEditingController refIdController = TextEditingController();
  final TextEditingController scopeIdController = TextEditingController();

  String selectedUser = "";
  String selectedService = "";
  String selectedSubject = "";
  String selectedQuoteStatus = "";
  String selectedPpt = "";
  String selectedFeasibilityStatus = "";
  String selectedCallStatus = "";
  String tlUsers = '';
  DateTimeRange? selectedDateRange;
  List<String> selectedTags = [];

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Palette.themeColor,
            colorScheme: ColorScheme.light(primary: Palette.themeColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tlUsers = prefs.getString('tl_users') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagData = ref.watch(tagsDropdownProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Ref ID", refIdController, Icons.numbers),
            const SizedBox(height: 8),
            _buildInputField("Scope ID", scopeIdController, Icons.numbers),
            const SizedBox(height: 8),
            _buildUserDropdown(),
            const SizedBox(height: 8),
            _buildServiceDropdown(),
            const SizedBox(height: 8),
            _buildDropdownField2("Subject", subjectMap, selectedSubject,
                (val) => setState(() => selectedSubject = val), Icons.person),
            const SizedBox(height: 8),
            _buildDropdownField(
              "Quote Status",
              [
                {"value": "PendingAtUser", "label": "Pending at User"},
                {"value": "PendingAtAdmin", "label": "Pending at Admin"},
                {"value": "1", "label": "Submitted"},
                {"value": "2", "label": "Discount Requested"},
                {"value": "3", "label": "Discount Submitted"},
              ],
              selectedQuoteStatus,
              (val) => setState(() => selectedQuoteStatus = val),
              Icons.assignment,
            ),
            const SizedBox(height: 8),
            _buildDropdownField(
              "PPT",
              [
                {"value": "Yes", "label": "Yes"},
              ],
              selectedPpt,
              (val) => setState(() => selectedPpt = val),
              Icons.picture_as_pdf,
            ),
            const SizedBox(height: 8),
            _buildDateRangePicker(),
            const SizedBox(height: 8),
            _buildDropdownField(
              "Feasibility Status",
              [
                {"value": "Pending", "label": "Pending"},
                {"value": "Completed", "label": "Completed"},
              ],
              selectedFeasibilityStatus,
              (val) => setState(() => selectedFeasibilityStatus = val),
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            _buildDropdownField(
              "Call Recording",
              [
                {"value": "1", "label": "Pending"},
              ],
              selectedCallStatus,
              (val) => setState(() => selectedCallStatus = val),
              Icons.call,
            ),
            tagData.when(
              data: (currencies) {
                final tagMap = {
                  for (var tag in currencies)
                    tag['tag_name'].toString(): tag['id'].toString(),
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CustomMultiSelectDropDown(
                      dropdownWidth: MediaQuery.sizeOf(context).width,
                      icon: Icons.tag,
                      items: tagMap,
                      title: 'Select Tags',
                      onSelectionChanged: (selectedIds) {
                        setState(() {
                          selectedTags = selectedIds;
                        });
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (err, stack) => Text("Error: ${err.toString()}"),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  String formatDate(DateTime? date) {
                    if (date == null) return '';
                    return "${date.year.toString().padLeft(4, '0')}-"
                        "${date.month.toString().padLeft(2, '0')}-"
                        "${date.day.toString().padLeft(2, '0')}";
                  }

                  widget.onFilterApplied({
                    'ref_id': refIdController.text,
                    'scope_id': scopeIdController.text,
                    'userId': selectedUser,
                    'subject_area': selectedSubject,
                    'service_name': selectedService,
                    'status': selectedQuoteStatus,
                    'ptp': selectedPpt,
                    'callrecordingpending': selectedCallStatus,
                    'feasability_status': selectedFeasibilityStatus,
                    'tags': selectedTags,
                    'start_date': formatDate(selectedDateRange?.start),
                    'end_date': formatDate(selectedDateRange?.end),
                  });
                },
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label:
                    const Text("Apply Filter", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    final displayText = selectedDateRange == null
        ? "Select Date Range"
        : "${selectedDateRange!.start.toLocal().toString().split(' ')[0]} to ${selectedDateRange!.end.toLocal().toString().split(' ')[0]}";

    return InkWell(
      onTap: () => _pickDateRange(context),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.date_range, size: 16, color: Palette.themeColor),
          labelStyle: const TextStyle(fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(displayText, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildInputField(
      String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: Palette.themeColor),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<Map<String, String>> options,
    String selectedValue,
    Function(String) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue.isEmpty ? null : selectedValue,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: Palette.themeColor),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child:
              Text(item['label'] ?? '', style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
      onChanged: (value) => onChanged(value ?? ''),
    );
  }

  Widget _buildDropdownField2(
    String label,
    Map<String, dynamic> options,
    String selectedValue,
    Function(String) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue.isEmpty ? null : selectedValue,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: Palette.themeColor),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: options.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value.toString(),
              style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
      onChanged: (value) => onChanged(value ?? ''),
    );
  }

  Widget _buildServiceDropdown() {
    final serviceData = ref.watch(serviceDropdownProvider);
    return serviceData.when(
      data: (services) => _buildDropdownField(
        "Service",
        services
            .map((e) => {
                  "label": e["name"].toString(),
                  "value": e["id"].toString(),
                })
            .toList(),
        selectedService,
        (val) => setState(() => selectedService = val),
        Icons.miscellaneous_services,
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => Text("Error: $err"),
    );
  }

  Widget _buildUserDropdown() {
    if (tlUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final userData = ref.watch(tlUserDropdownProvider(tlUsers));

    return userData.when(
      data: (usersMap) {
        final userOptions = usersMap.entries.map((entry) {
          return {
            "value": entry.key.toString(),
            "label":
                '${entry.value['fld_first_name']} ${entry.value['fld_last_name']}'
          };
        }).toList();

        return _buildDropdownField("User", userOptions, selectedUser,
            (val) => setState(() => selectedUser = val), Icons.person);
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => Text("Error: $err"),
    );
  }
}
