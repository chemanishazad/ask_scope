import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:loop/core/components/custom_dropdown.dart';
import 'package:loop/core/components/custom_multiselect.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/static_data.dart';

class AskForScopeTab extends ConsumerStatefulWidget {
  final String? selectedCurrencyId;
  final String? selectedServiceId;
  final String? selectedSubjectId;
  final String? selectedTagId;
  final String? customCurrencyType;
  final String? customSubjectType;
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
  final List<File> selectedFiles;
  final Function(String?) onCurrencyChanged;
  final Function(String?) onServiceChanged;
  final Function(String?) onSubjectChanged;
  final Function(String?) onTagChanged;
  final Function(bool?) onBasicChanged;
  final Function(bool?) onStandardChanged;
  final Function(bool?) onAdvancedChanged;
  final Function(String?) onCustomCurrencyChanged;
  final Function(String?) onCustomSubjectChanged;
  final Function() onPickFile;
  final Function(int) onRemoveFile;
  final Function() onSubmit;

  const AskForScopeTab({
    super.key,
    required this.selectedCurrencyId,
    required this.selectedServiceId,
    required this.selectedSubjectId,
    required this.selectedTagId,
    required this.customSubjectType,
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
    required this.selectedFiles,
    required this.onCurrencyChanged,
    required this.onServiceChanged,
    required this.onSubjectChanged,
    required this.onTagChanged,
    required this.onBasicChanged,
    required this.onStandardChanged,
    required this.onAdvancedChanged,
    required this.onCustomCurrencyChanged,
    required this.onCustomSubjectChanged,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onSubmit,
  });

  @override
  ConsumerState<AskForScopeTab> createState() => _AskForScopeTabState();
}

class _AskForScopeTabState extends ConsumerState<AskForScopeTab> {
  @override
  Widget build(BuildContext context) {
    final serviceData = ref.watch(serviceDropdownProvider);
    final currencyData = ref.watch(currencyDropdownProvider);
    final tagData = ref.watch(tagsDropdownProvider);

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
                        dropdownWidth: MediaQuery.sizeOf(context).width / 2.2,
                        icon: Icons.money,
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
                        dropdownWidth: MediaQuery.sizeOf(context).width / 2.2,
                        icon: Icons.design_services,
                        items: serviceMap, // Pass the map (name -> id)
                        title: 'Select Service',
                        onSelectionChanged: (selectedIds) {
                          widget.onServiceChanged(
                              selectedIds.join(', ')); // ✅ Send IDs
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  title('Subject Area'),
                  CustomDropDown(
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
          title('Select Plan'),
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
          if (widget.isBasicSelected) ...[
            const SizedBox(height: 8),
            const Text(
              "Add comment for Basic Plan",
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
          if (widget.isStandardSelected) ...[
            const SizedBox(height: 8),
            const Text(
              "Add comment for Standard Plan",
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
          if (widget.isAdvancedSelected) ...[
            const SizedBox(height: 8),
            const Text(
              "Add comment for Advanced Plan",
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
          tagData.when(
            data: (currencies) {
              final tagMap = {
                for (var tag in currencies)
                  tag['tag_name'].toString(): tag['id'].toString(),
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  title('Tags'),
                  CustomMultiSelectDropDown(
                    dropdownWidth: MediaQuery.sizeOf(context).width,
                    icon: Icons.tag,
                    items: tagMap,
                    title: 'Select Tags',
                    onSelectionChanged: (selectedIds) {
                      widget.onTagChanged(selectedIds.join(', ')); // ✅ Send IDs
                    },
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text("Error: ${err.toString()}"),
          ),
          const SizedBox(height: 6),
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
          title('Upload Files'),
          ElevatedButton.icon(
            onPressed: widget.onPickFile,
            icon: const Icon(
              Icons.photo_filter_sharp,
              color: Colors.white,
            ),
            label: const Text("Select Files"),
          ),
          if (widget.selectedFiles.isNotEmpty)
            Column(
              children: widget.selectedFiles.asMap().entries.map((entry) {
                int index = entry.key;
                File file = entry.value;

                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: cardDecoration(context: context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          file.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.onRemoveFile(index),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
        ),
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
