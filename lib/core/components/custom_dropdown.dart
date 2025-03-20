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

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.dropdownWidth,
      height: widget.dropdownHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: cardDecoration(context: context),
      child: DropdownButtonHideUnderline(
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.iconColor ?? theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  widget.title ?? 'Please select',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ), // Themed hint text style
                ),
                value: _selectedItem,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                iconSize: 20,
                elevation: 4,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface, // Dropdown text color
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedItem = newValue;
                    });
                    if (widget.onSelectionChanged != null) {
                      widget.onSelectionChanged!(newValue);
                    }
                  }
                },
                items:
                    widget.items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: theme.textTheme.bodySmall, // Themed menu item text
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
