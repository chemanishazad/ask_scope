import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/components/custom_dropdown.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/static_data.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:file_picker/file_picker.dart';

class AddNewScope extends ConsumerStatefulWidget {
  const AddNewScope({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNewScopeState();
}

class _AddNewScopeState extends ConsumerState<AddNewScope>
    with SingleTickerProviderStateMixin {
  String? selectedCurrencyId;
  String? selectedServiceId;
  String? selectedSubjectId;
  String? selectedTagId;
  late TabController _tabController;

  bool isBasicSelected = false;
  bool isStandardSelected = false;
  bool isAdvancedSelected = false;
  final HtmlEditorController _basicController = HtmlEditorController();
  final HtmlEditorController _standardController = HtmlEditorController();
  final HtmlEditorController _advancedController = HtmlEditorController();
  final HtmlEditorController _commentController = HtmlEditorController();
  final TextEditingController _basicWordCountController =
      TextEditingController();
  final TextEditingController _standardWordCountController =
      TextEditingController();
  final TextEditingController _advancedWordCountController =
      TextEditingController();
  String _basicWordCountText = "";
  String _standardWordCountText = "";
  String _advancedWordCountText = "";
  List<File> _selectedFiles = [];

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files.map((file) => File(file.path!)));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _basicWordCountController.addListener(_updateBasicWordCountText);
    _standardWordCountController.addListener(_updateStandardWordCountText);
    _advancedWordCountController.addListener(_updateAdvancedWordCountText);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      print('Client Name: ${args['clientName']}');
      print('Ref ID: ${args['refId']}');
    }
  }

  void _updateBasicWordCountText() {
    setState(() {
      int? count = int.tryParse(_basicWordCountController.text);
      _basicWordCountText = (count != null)
          ? NumberToWord().convert('en-in', count) // Converts number to words
          : "";
    });
  }

  void _updateStandardWordCountText() {
    setState(() {
      int? count = int.tryParse(_standardWordCountController.text);
      _standardWordCountText = (count != null)
          ? NumberToWord().convert('en-in', count) // Converts number to words
          : "";
    });
  }

  void _updateAdvancedWordCountText() {
    setState(() {
      int? count = int.tryParse(_advancedWordCountController.text);
      _advancedWordCountText = (count != null)
          ? NumberToWord().convert('en-in', count) // Converts number to words
          : "";
    });
  }

  @override
  void dispose() {
    _basicWordCountController.removeListener(_updateBasicWordCountText);
    _standardWordCountController.removeListener(_updateStandardWordCountText);
    _advancedWordCountController.removeListener(_updateAdvancedWordCountText);
    _basicWordCountController.dispose();
    _standardWordCountController.dispose();
    _advancedWordCountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validation
    if (selectedCurrencyId == null) {
      _showError("Please select a currency.");
      return;
    }
    if (selectedServiceId == null) {
      _showError("Please select a service.");
      return;
    }
    if (selectedSubjectId == null) {
      _showError("Please select a subject.");
      return;
    }
    if (selectedTagId == null) {
      _showError("Please select a tag.");
      return;
    }
    if (!isBasicSelected && !isStandardSelected && !isAdvancedSelected) {
      _showError("Please select at least one plan.");
      return;
    }

    // Print selected values
    print("Selected Currency ID: $selectedCurrencyId");
    print("Selected Service ID: $selectedServiceId");
    print("Selected Subject ID: $selectedSubjectId");
    print("Selected Tag ID: $selectedTagId");
    print("Basic Plan Selected: $isBasicSelected");
    print("Standard Plan Selected: $isStandardSelected");
    print("Advanced Plan Selected: $isAdvancedSelected");

    // Show success message
    _showSuccess("Form submitted successfully!");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceData = ref.watch(serviceDropdownProvider);
    final currencyData = ref.watch(currencyDropdownProvider);
    final tagData = ref.watch(tagsDropdownProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Palette.themeColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.info, size: 18), text: "Ask For Scope"),
              Tab(
                  icon: Icon(Icons.perm_device_info_outlined, size: 18),
                  text: "Ask For Feasibility Check"),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // custom widget
                  SingleChildScrollView(
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
                                    currency['name'].toString():
                                        currency['id'].toString(),
                                };

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    title('Currency'),
                                    CustomDropDown(
                                      dropdownWidth:
                                          MediaQuery.sizeOf(context).width /
                                              2.2,
                                      icon: Icons.currency_rupee_rounded,
                                      items: currencyMap.keys.toList(),
                                      title: 'Select Currency',
                                      onSelectionChanged: (selectedName) {
                                        setState(() {
                                          selectedCurrencyId =
                                              currencyMap[selectedName];
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (err, stack) =>
                                  Text("Error: ${err.toString()}"),
                            ),
                            serviceData.when(
                              data: (services) {
                                final serviceMap = {
                                  for (var service in services)
                                    service['name'].toString():
                                        service['id'].toString(),
                                };

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    title('Service'),
                                    CustomDropDown(
                                      dropdownWidth:
                                          MediaQuery.sizeOf(context).width /
                                              2.2,
                                      icon: Icons.design_services,
                                      items: serviceMap.keys.toList(),
                                      title: 'Select Service',
                                      onSelectionChanged: (selectedName) {
                                        setState(() {
                                          selectedServiceId =
                                              serviceMap[selectedName];
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (err, stack) =>
                                  Text("Error: ${err.toString()}"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        title('Subject Area'),
                        CustomDropDown(
                          dropdownWidth: MediaQuery.sizeOf(context).width,
                          icon: Icons.subject,
                          items: subjectMap.keys.toList(),
                          title: 'Select Subject',
                          onSelectionChanged: (selectedName) {
                            setState(() {
                              selectedSubjectId = subjectMap[selectedName];
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        title('Select Level'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            checkboxWithLabel(
                              label: 'Basic',
                              value: isBasicSelected,
                              color: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  isBasicSelected = value!;
                                });
                              },
                            ),
                            checkboxWithLabel(
                              label: 'Standard',
                              value: isStandardSelected,
                              color: Colors.orange,
                              onChanged: (bool? value) {
                                setState(() {
                                  isStandardSelected = value!;
                                });
                              },
                            ),
                            checkboxWithLabel(
                              label: 'Advance',
                              value: isAdvancedSelected,
                              color: Colors.red,
                              onChanged: (bool? value) {
                                setState(() {
                                  isAdvancedSelected = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        tagData.when(
                          data: (currencies) {
                            final tagMap = {
                              for (var tag in currencies)
                                tag['tag_name'].toString():
                                    tag['id'].toString(),
                            };

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title('Tags'),
                                CustomDropDown(
                                  dropdownWidth:
                                      MediaQuery.sizeOf(context).width / 2.2,
                                  icon: Icons.tag,
                                  items: tagMap.keys.toList(),
                                  title: 'Select Tags',
                                  onSelectionChanged: (selectedName) {
                                    setState(() {
                                      selectedTagId = tagMap[selectedName];
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (err, stack) =>
                              Text("Error: ${err.toString()}"),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Additional Comments (optional)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        HtmlEditor(
                          controller: _commentController,
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
                              InsertButtons(
                                  table: false, video: false, audio: false),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        if (isBasicSelected) ...[
                          const Text(
                            "Add comment for Basic Plan (optional)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          HtmlEditor(
                            controller: _basicController,
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
                                InsertButtons(
                                    table: false, video: false, audio: false),
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
                                width: MediaQuery.sizeOf(context).width / 2,
                                child: TextField(
                                  controller: _basicWordCountController,
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
                              Expanded(
                                child: Text(
                                  _basicWordCountText.isNotEmpty
                                      ? _basicWordCountText
                                      : "",
                                ),
                              ),
                            ],
                          )
                        ],
                        const SizedBox(height: 8),
                        if (isStandardSelected) ...[
                          const Text(
                            "Add comment for Standard Plan (optional)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          HtmlEditor(
                            controller: _standardController,
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
                                InsertButtons(
                                    table: false, video: false, audio: false),
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
                                width: MediaQuery.sizeOf(context).width / 2,
                                child: TextField(
                                  controller: _standardWordCountController,
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
                              Expanded(
                                child: Text(
                                  _standardWordCountText.isNotEmpty
                                      ? _standardWordCountText
                                      : "",
                                ),
                              ),
                            ],
                          )
                        ],
                        const SizedBox(height: 8),
                        if (isAdvancedSelected) ...[
                          const Text(
                            "Add comment for Advanced Plan (optional)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          HtmlEditor(
                            controller: _advancedController,
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
                                InsertButtons(
                                    table: false, video: false, audio: false),
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
                                width: MediaQuery.sizeOf(context).width / 2,
                                child: TextField(
                                  controller: _advancedWordCountController,
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
                              Expanded(
                                child: Text(_advancedWordCountText.isNotEmpty
                                    ? _advancedWordCountText
                                    : ""),
                              ),
                            ],
                          )
                        ],
                        title('Upload Files'),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(
                            Icons.photo_filter_sharp,
                            color: Colors.white,
                          ),
                          label: const Text("Select Files"),
                        ),
                        if (_selectedFiles.isNotEmpty)
                          Column(
                            children:
                                _selectedFiles.asMap().entries.map((entry) {
                              int index = entry.key;
                              File file = entry.value;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: cardDecoration(context: context),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        file.path.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _removeFile(index),
                                      child: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Submit')),
                        )
                      ],
                    ),
                  ),
                  const Center(child: Text("Communication Data")),
                ],
              ),
            ),
          ],
        ),
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
