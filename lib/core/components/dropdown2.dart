import 'package:flutter/material.dart';
import 'package:loop/core/const/styles.dart';

class CustomDropDown2 extends StatefulWidget {
  final List<String> items;
  final Function(List<String>)? onSelectionChanged;
  final IconData icon;
  final String? title;
  final List<String>? initialValues;
  final int? maxSelections; // Optional max selections

  const CustomDropDown2({
    Key? key,
    required this.items,
    this.onSelectionChanged,
    this.icon = Icons.arrow_drop_down,
    this.title,
    this.initialValues,
    this.maxSelections, // Add this parameter
  }) : super(key: key);

  @override
  State<CustomDropDown2> createState() => _CustomDropDown2State();
}

class _CustomDropDown2State extends State<CustomDropDown2> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialValues ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMultiSelectDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: cardDecoration(context: context),
        child: Row(
          children: [
            Icon(widget.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedItems.isNotEmpty
                    ? _selectedItems.join(', ') // Show selected names
                    : (widget.title ?? 'Please select'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context) async {
    final List<String> selected = await showDialog(
          context: context,
          builder: (context) {
            return MultiSelectDialog(
              items: widget.items,
              initialSelectedItems: _selectedItems,
              maxSelections: widget.maxSelections, // Pass max selections
            );
          },
        ) ??
        _selectedItems;

    setState(() {
      _selectedItems = selected;
    });

    widget.onSelectionChanged?.call(_selectedItems);
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final int? maxSelections; // Make maxSelections nullable

  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedItems,
    this.maxSelections,
  }) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedItems;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where(
            (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return AlertDialog(
      title: const Text('Select Options'),
      content: SizedBox(
        height: 400,
        width: 300,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return CheckboxListTile(
                    value: _tempSelectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          if (widget.maxSelections == null ||
                              _tempSelectedItems.length <
                                  widget.maxSelections!) {
                            _tempSelectedItems.add(item);
                          } else {
                            // Inform user about max selections
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maximum selections reached'),
                              ),
                            );
                          }
                        } else {
                          _tempSelectedItems.remove(item);
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
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, widget.initialSelectedItems);
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context, _tempSelectedItems);
          },
        ),
      ],
    );
  }
}
