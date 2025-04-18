import 'package:flutter/material.dart';

class CustomMultiSelectDropDown extends StatefulWidget {
  final Map<String, String> items; // Name -> ID map
  final Function(List<String>)? onSelectionChanged;
  final IconData icon;
  final String title;
  final Color? iconColor;
  final List<String>? initialValues;
  final double dropdownWidth;
  final double dropdownHeight;
  final String dialogTitle;

  const CustomMultiSelectDropDown({
    super.key,
    required this.items,
    this.onSelectionChanged,
    this.icon = Icons.arrow_drop_down,
    this.title = 'Select Items',
    this.initialValues,
    this.iconColor,
    this.dropdownWidth = 200,
    this.dropdownHeight = 45,
    this.dialogTitle = "Select Items",
  });

  @override
  State<CustomMultiSelectDropDown> createState() =>
      _CustomMultiSelectDropDownState();
}

class _CustomMultiSelectDropDownState extends State<CustomMultiSelectDropDown> {
  List<String> _selectedNames = [];
  List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _selectedIds = widget.initialValues!;
      _selectedNames = widget.items.entries
          .where((entry) => _selectedIds.contains(entry.value))
          .map((entry) => entry.key)
          .toList();
    }
  }

  void _showMultiSelectDialog() async {
    final List<String>? selectedValues = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: widget.dialogTitle,
          items: widget.items,
          selectedItems: _selectedNames,
        );
      },
    );

    if (selectedValues != null) {
      setState(() {
        _selectedNames = selectedValues;
        _selectedIds =
            selectedValues.map((name) => widget.items[name]!).toList();
      });

      if (widget.onSelectionChanged != null) {
        widget.onSelectionChanged!(_selectedIds); // Return selected IDs
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedText =
        _selectedNames.isEmpty ? widget.title : _selectedNames.join(', ');

    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: Container(
        width: widget.dropdownWidth,
        height: widget.dropdownHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: widget.iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 22, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final Map<String, String> items;
  final List<String> selectedItems;
  final String title;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.selectedItems,
    this.title = "Select Items",
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _filteredList;
  late List<String> _selectedItems;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredList = widget.items.keys.toList();
    _selectedItems = List.from(widget.selectedItems);
  }

  void _filterList(String query) {
    setState(() {
      _filteredList = widget.items.keys
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterList,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final name = _filteredList[index];
                  final isSelected = _selectedItems.contains(name);
                  return CheckboxListTile(
                    title: Text(name),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedItems.add(name);
                        } else {
                          _selectedItems.remove(name);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("CANCEL"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedItems),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
