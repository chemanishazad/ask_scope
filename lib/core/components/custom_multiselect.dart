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

  const CustomMultiSelectDropDown({
    super.key,
    required this.items,
    this.onSelectionChanged,
    this.icon = Icons.arrow_drop_down,
    this.title = 'Select Items',
    this.initialValues,
    this.iconColor,
    this.dropdownWidth = 200,
    this.dropdownHeight = 40,
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
          items: widget.items,
          selectedItems: _selectedNames, // Pass selected names
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
        widget.onSelectionChanged!(_selectedIds); // ✅ Pass IDs
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedText =
        _selectedNames.isEmpty ? widget.title : _selectedNames.join(', ');

    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: Container(
        width: widget.dropdownWidth,
        height: widget.dropdownHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: Icon(Icons.arrow_drop_down_outlined,
                  color: Colors.grey, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final Map<String, String> items;
  final List<String> selectedItems;

  const MultiSelectDialog(
      {super.key, required this.items, required this.selectedItems});

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Services"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.keys.map((name) {
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
          }).toList(),
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
