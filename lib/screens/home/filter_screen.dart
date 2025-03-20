import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/provider/home/home_provider.dart';

class FilterBar extends StatefulWidget {
  final Function(String, String, String) onFilterApplied;

  const FilterBar({super.key, required this.onFilterApplied});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final TextEditingController refIdController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();
  String selectedWebsite = "Select Website";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField("Ref ID", refIdController),
        _buildTextField("Enter Search Keywords", keywordController),
        _buildDropdown(),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onFilterApplied(
                refIdController.text,
                keywordController.text,
                selectedWebsite == "Select Website" ? "" : selectedWebsite,
              );
            },
            icon: const Icon(Icons.filter_alt_rounded, size: 18),
            label: const Text("Apply"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final websiteData = ref.watch(websiteProvider);

        return websiteData.when(
          data: (websites) {
            return DropdownButtonFormField<String>(
              value:
                  selectedWebsite == "Select Website" ? null : selectedWebsite,
              decoration: InputDecoration(
                labelText: "Select Website",
                labelStyle: TextStyle(fontSize: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              items: websites.map<DropdownMenuItem<String>>((website) {
                return DropdownMenuItem<String>(
                  value: website["id"],
                  child: Text(
                    website["website"],
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedWebsite = value!);
              },
              icon: Icon(Icons.arrow_drop_down, size: 20),
              dropdownColor: Colors.white,
              style: TextStyle(fontSize: 14, color: Colors.black),
            );
          },
          loading: () => SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (err, stack) =>
              Text("Error loading websites", style: TextStyle(fontSize: 14)),
        );
      },
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
