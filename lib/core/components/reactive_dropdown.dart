import 'package:flutter/material.dart';
import 'package:loop/core/const/palette.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveDropdown<T> extends StatelessWidget {
  final String formControlName;
  final String hintText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final Map<String, ValidationMessageFunction>? validationMessages;

  const CustomReactiveDropdown({
    super.key,
    required this.formControlName,
    required this.hintText,
    required this.items,
    this.validationMessages,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReactiveDropdownField<T>(
      formControlName: formControlName,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: Palette.blackColor,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: theme.iconTheme.color)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 18.0,
        ),
      ),
      dropdownColor: theme.cardColor,
      items: items,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Palette.blackColor,
      ),
      validationMessages: validationMessages,
    );
  }
}
