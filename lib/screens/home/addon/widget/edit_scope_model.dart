import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:loop/core/components/custom_dropdown.dart';
import 'package:loop/core/components/custom_multiselect.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/static_data.dart';

class EditScopeModel extends ConsumerStatefulWidget {
  final String? selectedCurrencyId;
  final String? selectedServiceId;
  final String? selectedSubjectId;
  final String? customCurrencyType;
  final bool isBasicSelected;
  final bool isStandardSelected;
  final bool isAdvancedSelected;
  final HtmlEditorController basicController;
  final HtmlEditorController standardController;
  final HtmlEditorController advancedController;
  final HtmlEditorController commentController;
  final TextEditingController basicWordCountController;
  final TextEditingController standardWordCountController;
  final TextEditingController advancedWordCountController;
  final String basicWordCountText;
  final String standardWordCountText;
  final String advancedWordCountText;
  final Function(String?) onCurrencyChanged;
  final Function(String?) onServiceChanged;
  final Function(String?) onSubjectChanged;
  final Function(String?) onTagChanged;
  final Function(String?) onUserChanged;
  final Function(bool?) onBasicChanged;
  final Function(bool?) onStandardChanged;
  final Function(bool?) onAdvancedChanged;
  final Function(String?) onCustomCurrencyChanged;
  final Function() onSubmit;

  const EditScopeModel({
    super.key,
    required this.selectedCurrencyId,
    required this.selectedServiceId,
    required this.selectedSubjectId,
    required this.customCurrencyType,
    required this.isBasicSelected,
    required this.isStandardSelected,
    required this.isAdvancedSelected,
    required this.basicController,
    required this.standardController,
    required this.advancedController,
    required this.commentController,
    required this.basicWordCountController,
    required this.standardWordCountController,
    required this.advancedWordCountController,
    required this.basicWordCountText,
    required this.standardWordCountText,
    required this.advancedWordCountText,
    required this.onCurrencyChanged,
    required this.onServiceChanged,
    required this.onSubjectChanged,
    required this.onTagChanged,
    required this.onUserChanged,
    required this.onBasicChanged,
    required this.onStandardChanged,
    required this.onAdvancedChanged,
    required this.onCustomCurrencyChanged,
    required this.onSubmit,
  });

  @override
  ConsumerState<EditScopeModel> createState() => _EditScopeModelState();
}

class _EditScopeModelState extends ConsumerState<EditScopeModel> {
  @override
  Widget build(BuildContext context) {
    final serviceData = ref.watch(serviceDropdownProvider);
    final currencyData = ref.watch(currencyDropdownProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              currencyData.when(
                data: (currencies) {
                  final currencyMap = {
                    for (var currency in currencies)
                      currency['name'].toString(): currency['id'].toString(),
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title('Currency'),
                      CustomDropDown(
                        initialValue: widget.selectedCurrencyId,
                        dropdownWidth: MediaQuery.sizeOf(context).width / 2.2,
                        icon: Icons.currency_rupee_rounded,
                        items: currencyMap.keys.toList(),
                        title: 'Select Currency',
                        onSelectionChanged: widget.onCurrencyChanged,
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text("Error: ${err.toString()}"),
              ),
              serviceData.when(
                data: (services) {
                  final Map<String, String> serviceMap = {
                    for (var service in services)
                      service['name'].toString(): service['id'].toString(),
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title('Service'),
                      CustomMultiSelectDropDown(
                        initialValues:
                            widget.selectedServiceId?.isNotEmpty == true
                                ? widget.selectedServiceId!.split(',')
                                : [],
                        dropdownWidth: MediaQuery.sizeOf(context).width / 2.2,
                        icon: Icons.design_services,
                        items: serviceMap,
                        title: 'Select Service',
                        onSelectionChanged: (selectedIds) {
                          widget.onServiceChanged(selectedIds.join(', '));
                        },
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text("Error: ${err.toString()}"),
              ),
            ],
          ),
          if (widget.selectedCurrencyId == 'Other')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                title('Other Currency Name'),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter currency",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      prefixIcon: const Icon(Icons.currency_exchange,
                          size: 20, color: Palette.themeColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                    ),
                    onChanged: widget.onCustomCurrencyChanged,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  title('Subject Area'),
                  CustomDropDown(
                    initialValue: widget.selectedSubjectId,
                    dropdownWidth: MediaQuery.sizeOf(context).width / 2.2,
                    icon: Icons.subject,
                    items: subjectMap.keys.toList(),
                    title: 'Select Subject',
                    onSelectionChanged: widget.onSubjectChanged,
                  ),
                ],
              ),
              if (widget.selectedSubjectId == 'Other')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title('Other Subject Name'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Subject",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          prefixIcon: const Icon(Icons.book,
                              size: 20, color: Palette.themeColor),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5),
                          ),
                        ),
                        onChanged: widget.onCustomCurrencyChanged,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          title('Select Level'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              checkboxWithLabel(
                label: 'Basic',
                value: widget.isBasicSelected,
                color: Colors.green,
                onChanged: widget.onBasicChanged,
              ),
              checkboxWithLabel(
                label: 'Standard',
                value: widget.isStandardSelected,
                color: Colors.orange,
                onChanged: widget.onStandardChanged,
              ),
              checkboxWithLabel(
                label: 'Advance',
                value: widget.isAdvancedSelected,
                color: Colors.red,
                onChanged: widget.onAdvancedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.isBasicSelected) ...[
            const Text(
              "Add comment for Basic Plan (optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            HtmlEditor(
              controller: widget.basicController,
              htmlEditorOptions: const HtmlEditorOptions(
                hint: "Add comment for Basic plan",
              ),
              otherOptions: const OtherOptions(
                height: 200,
              ),
              htmlToolbarOptions: const HtmlToolbarOptions(
                defaultToolbarButtons: [
                  FontButtons(clearAll: false),
                  ParagraphButtons(
                    alignCenter: true,
                    alignLeft: true,
                    alignRight: true,
                    lineHeight: false,
                    textDirection: false,
                  ),
                  InsertButtons(table: false, video: false, audio: false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter Word Count for Basic Plan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width / 2.5,
                  child: TextField(
                    controller: widget.basicWordCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter word count",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.basicWordCountText.isNotEmpty
                        ? widget.basicWordCountText
                        : "",
                  ),
                ),
              ],
            )
          ],
          const SizedBox(height: 8),
          if (widget.isStandardSelected) ...[
            const Text(
              "Add comment for Standard Plan (optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            HtmlEditor(
              controller: widget.standardController,
              htmlEditorOptions: const HtmlEditorOptions(
                hint: "Add comment for Standard plan",
              ),
              otherOptions: const OtherOptions(
                height: 200,
              ),
              htmlToolbarOptions: const HtmlToolbarOptions(
                defaultToolbarButtons: [
                  FontButtons(clearAll: false),
                  ParagraphButtons(
                    alignCenter: true,
                    alignLeft: true,
                    alignRight: true,
                    lineHeight: false,
                    textDirection: false,
                  ),
                  InsertButtons(table: false, video: false, audio: false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter Word Count for Standard Plan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width / 2.5,
                  child: TextField(
                    controller: widget.standardWordCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter word count",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.standardWordCountText.isNotEmpty
                        ? widget.standardWordCountText
                        : "",
                  ),
                ),
              ],
            )
          ],
          const SizedBox(height: 8),
          if (widget.isAdvancedSelected) ...[
            const Text(
              "Add comment for Advanced Plan (optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            HtmlEditor(
              controller: widget.advancedController,
              htmlEditorOptions: const HtmlEditorOptions(
                hint: "Add comment for Advanced plan",
              ),
              otherOptions: const OtherOptions(
                height: 200,
              ),
              htmlToolbarOptions: const HtmlToolbarOptions(
                defaultToolbarButtons: [
                  FontButtons(clearAll: false),
                  ParagraphButtons(
                    alignCenter: true,
                    alignLeft: true,
                    alignRight: true,
                    lineHeight: false,
                    textDirection: false,
                  ),
                  InsertButtons(table: false, video: false, audio: false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter Word Count for Advanced Plan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.sizeOf(context).width / 2.5,
                  child: TextField(
                    controller: widget.advancedWordCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter word count",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.advancedWordCountText.isNotEmpty
                        ? widget.advancedWordCountText
                        : "",
                  ),
                ),
              ],
            )
          ],
          const Text(
            "Additional Comments (optional)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          HtmlEditor(
            
            controller: widget.commentController,
            htmlEditorOptions: const HtmlEditorOptions(
              hint: "Additional Comments",
            ),
            otherOptions: const OtherOptions(
              height: 200,
            ),
            htmlToolbarOptions: const HtmlToolbarOptions(
              defaultToolbarButtons: [
                FontButtons(clearAll: false),
                ParagraphButtons(
                  alignCenter: true,
                  alignLeft: true,
                  alignRight: true,
                  lineHeight: false,
                  textDirection: false,
                ),
                InsertButtons(table: false, video: false, audio: false),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
      ),
    );
  }

  Widget checkboxWithLabel({
    required String label,
    required bool value,
    required Color color,
    required Function(bool?) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: color,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
