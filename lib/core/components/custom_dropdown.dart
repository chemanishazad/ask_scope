import 'package:flutter/material.dart';
import 'package:loop/core/const/styles.dart';

class CustomDropDown extends StatefulWidget {
  final List<String> items;
  final Function(String)? onSelectionChanged;
  final IconData icon;
  final String? title;
  final Color? iconColor;
  final String? initialValue;
  final double dropdownWidth;
  final double dropdownHeight;

  const CustomDropDown({
    super.key,
    required this.items,
    this.onSelectionChanged,
    this.icon = Icons.arrow_drop_down,
    this.title,
    this.initialValue,
    this.iconColor,
    this.dropdownWidth = 120,
    this.dropdownHeight = 40,
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String? _selectedItem;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null &&
        widget.items.contains(widget.initialValue)) {
      _selectedItem = widget.initialValue;
    }
  }

  void _openSearchDialog() {
    List<String> filteredItems = [...widget.items];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: SizedBox(
            width: 300,
            height: 500,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredItems = widget.items
                              .where((item) => item
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredItems.isNotEmpty
                          ? ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    filteredItems[index],
                                    style: const TextStyle(fontSize: 10.0),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedItem = filteredItems[index];
                                      _searchController.clear();
                                    });
                                    if (widget.onSelectionChanged != null) {
                                      widget.onSelectionChanged!(
                                          filteredItems[index]);
                                    }
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            )
                          : const Center(child: Text('No items found')),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _openSearchDialog,
      child: Container(
        width: widget.dropdownWidth,
        height: widget.dropdownHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: cardDecoration(context: context),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.iconColor ?? theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _selectedItem ?? widget.title ?? 'Please select',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  color: _selectedItem == null
                      ? Colors.grey
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
