import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SimpleDropdownDialog extends StatelessWidget {
  final FormGroup formGroup;
  final String formControlName;
  final String title;
  final List<Map<String, String>> items;
  final Widget? iconData;

  const SimpleDropdownDialog({
    super.key,
    required this.formGroup,
    required this.formControlName,
    required this.items,
    required this.title,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.headlineMedium),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () async {
            String? selectedValue = await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(title, style: theme.headlineLarge),
                  content: SingleChildScrollView(
                    child: Column(
                      children: items.map((item) {
                        return ListTile(
                          title:
                              Text(item['title'] ?? '', style: theme.bodyLarge),
                          onTap: () {
                            Navigator.pop(context, item['value']);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );

            if (selectedValue != null) {
              formGroup.control(formControlName).value = selectedValue;
            }
          },
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconData ?? const Icon(Icons.manage_accounts_outlined),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      formGroup.control(formControlName).value ??
                          'Select an option',
                      style: theme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
