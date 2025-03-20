import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loop/core/const/palette.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class CustomReactiveTextField extends StatefulWidget {
  final String formControlName;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool readOnly;
  final TextEditingController? controller;

  const CustomReactiveTextField({
    super.key,
    required this.formControlName,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.controller,
  });

  @override
  State<CustomReactiveTextField> createState() =>
      _CustomReactiveTextFieldState();
}

class _CustomReactiveTextFieldState extends State<CustomReactiveTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? inputFormatters;
    if (widget.formControlName == 'companyCode') {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          String upperCaseText = newValue.text.toUpperCase();
          return TextEditingValue(
            text: upperCaseText,
            selection: TextSelection.collapsed(offset: upperCaseText.length),
          );
        }),
      ];
    } else if (widget.formControlName == 'expectedCtC' ||
        widget.formControlName == 'currentCtc' ||
        widget.formControlName == 'fixed' ||
        widget.formControlName == 'variable') {
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ];
    } else if (widget.formControlName == 'relevantExp' ||
        widget.formControlName == 'noticePeriod' ||
        widget.formControlName == 'age' ||
        widget.formControlName == '') {
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ];
    }
    final theme = Theme.of(context).textTheme;
    if (widget.formControlName == 'password' ||
        widget.formControlName == 'confirmPassword') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.headlineMedium,
            ),
            SizedBox(height: 1.h),
            ReactiveTextField(
              formControlName: widget.formControlName,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(widget.icon),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                filled: true,
                fillColor: Palette.whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Palette.blackColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Palette.themeColor,
                    )),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.red,
                    )),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly,
              controller: widget.controller,
              validationMessages: {
                'required': (control) => '${widget.label} is required',
                'minLength': (control) =>
                    'Please enter a minimum of 6 characters',
              },
            ),
          ],
        ),
      );
    }

    if (widget.formControlName == 'dob') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.headlineMedium,
            ),
            SizedBox(height: 1.h),
            ReactiveDatePicker<DateTime>(
              formControlName: widget.formControlName,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, picker, child) {
                return InkWell(
                  onTap: picker.showPicker,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      prefixIcon: Icon(widget.icon),
                      filled: true,
                      fillColor: Palette.whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: picker.value == null
                        ? Text(
                            widget.hint,
                            style:
                                theme.bodyMedium?.copyWith(color: Colors.grey),
                          )
                        : Text(
                            DateFormat('dd-MM-yyyy').format(picker.value!),
                            style: theme.bodyMedium,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.headlineMedium,
          ),
          SizedBox(height: 1.h),
          ReactiveTextField(
            formControlName: widget.formControlName,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon),
              filled: true,
              fillColor: Palette.whiteColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Palette.blackColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Palette.themeColor,
                  )),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.red,
                  )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: inputFormatters,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            textCapitalization: (widget.formControlName == 'name' ||
                    widget.formControlName == 'secondName')
                ? TextCapitalization.words
                : TextCapitalization.none,
            validationMessages: {
              'required': (control) => '${widget.label} is required',
              'minLength': (control) =>
                  'Please enter a minimum of 8 characters',
              'email': (control) => 'Please enter a valid email address',
              'pattern': (control) =>
                  'Please enter a valid format phone number',
            },
          ),
        ],
      ),
    );
  }
}
