import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/model/home/edit_scope_model.dart';
import 'package:loop/provider/home/scope_upload_provider.dart';
import 'package:loop/screens/home/addon/widget/edit_scope_model.dart';
import 'package:number_to_words/number_to_words.dart';

class EditScopeScreen extends ConsumerStatefulWidget {
  const EditScopeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditScopeScreenState();
}

class _EditScopeScreenState extends ConsumerState<EditScopeScreen> {
  Map<String, dynamic> formData = {};
  bool _isInitialized = false;

  String selectedCurrencyId = "";
  String selectedServiceId = "";
  String selectedSubjectId = "";
  String selectedUserId = "";
  String selectedTagId = "";
  String customCurrencyType = "";
  String customSubjectType = "";
  bool isBasicSelected = false;
  bool isStandardSelected = false;
  bool isAdvancedSelected = false;

  late final HtmlEditorController _basicController;
  late final HtmlEditorController _standardController;
  late final HtmlEditorController _advancedController;
  late final HtmlEditorController _commentController;
  late final TextEditingController _basicWordCountController;
  late final TextEditingController _standardWordCountController;
  late final TextEditingController _advancedWordCountController;

  String _basicWordCountText = "";
  String _standardWordCountText = "";
  String _advancedWordCountText = "";
  String basicPlanText = "";
  String standardPlanText = "";
  String advancedPlanText = "";
  String commentText = "";
  String feasibilityUser = "";
  String isFeasibility = "";

  @override
  void initState() {
    super.initState();
    _basicController = HtmlEditorController();
    _standardController = HtmlEditorController();
    _advancedController = HtmlEditorController();
    _commentController = HtmlEditorController();
    _basicWordCountController = TextEditingController();
    _standardWordCountController = TextEditingController();
    _advancedWordCountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Add listeners only once
    _basicWordCountController.removeListener(_updateBasicWordCountText);
    _standardWordCountController.removeListener(_updateStandardWordCountText);
    _advancedWordCountController.removeListener(_updateAdvancedWordCountText);

    _basicWordCountController.addListener(_updateBasicWordCountText);
    _standardWordCountController.addListener(_updateStandardWordCountText);
    _advancedWordCountController.addListener(_updateAdvancedWordCountText);

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _initializeFormData(args);
        _isInitialized = true;
      }
    }
  }

  void _initializeFormData(Map<String, dynamic> args) {
    setState(() {
      formData = Map<String, dynamic>.from(args);
      selectedCurrencyId = formData["currency"] ?? "";
      selectedServiceId = formData["service_id"] ?? "";
      selectedSubjectId = formData["subject_area"] ?? "";
      selectedUserId = formData["user_id"] ?? "";
      customCurrencyType = formData["other_currency"] ?? "";
      customSubjectType = formData["other_subject_area"] ?? "";
      isFeasibility = formData["isfeasability"] ?? "";
      feasibilityUser = formData['feasability_user'] ?? "";

      final planString = formData["plan"] ?? "";
      isBasicSelected = planString.contains("Basic");
      isStandardSelected = planString.contains("Standard");
      isAdvancedSelected = planString.contains("Advanced");

      _basicWordCountController.text = formData["plan_word_counts_Basic"] ?? "";
      _standardWordCountController.text =
          formData["plan_word_counts_Standard"] ?? "";
      _advancedWordCountController.text =
          formData["plan_word_counts_Advanced"] ?? "";
    });

    // Initialize editors after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditors();
    });
  }

  void _initializeEditors() {
    // Add a small delay to ensure editors are ready
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        if (formData['plan_comments_Basic'] != null &&
            formData['plan_comments_Basic'].toString().isNotEmpty) {
          _basicController.setText(formData['plan_comments_Basic'].toString());
          debugPrint(
              'Basic editor initialized with: ${formData['plan_comments_Basic']}');
        }
        if (formData['plan_comments_Standard'] != null &&
            formData['plan_comments_Standard'].toString().isNotEmpty) {
          _standardController
              .setText(formData['plan_comments_Standard'].toString());
          debugPrint(
              'Standard editor initialized with: ${formData['plan_comments_Standard']}');
        }
        if (formData['plan_comments_Advanced'] != null &&
            formData['plan_comments_Advanced'].toString().isNotEmpty) {
          _advancedController
              .setText(formData['plan_comments_Advanced'].toString());
          debugPrint(
              'Advanced editor initialized with: ${formData['plan_comments_Advanced']}');
        }
        if (formData['comments'] != null &&
            formData['comments'].toString().isNotEmpty) {
          _commentController.setText(formData['comments'].toString());
          debugPrint(
              'Comment editor initialized with: ${formData['comments']}');
        }
      } catch (e) {
        debugPrint('Error initializing editors: $e');
      }
    });
  }

  void _updateBasicWordCountText() {
    final count = int.tryParse(_basicWordCountController.text);
    setState(() {
      _basicWordCountText =
          (count != null) ? NumberToWord().convert('en-in', count) : "";
    });
  }

  void _updateStandardWordCountText() {
    final count = int.tryParse(_standardWordCountController.text);
    setState(() {
      _standardWordCountText =
          (count != null) ? NumberToWord().convert('en-in', count) : "";
    });
  }

  void _updateAdvancedWordCountText() {
    final count = int.tryParse(_advancedWordCountController.text);
    setState(() {
      _advancedWordCountText =
          (count != null) ? NumberToWord().convert('en-in', count) : "";
    });
  }

  Future<void> _submitForm() async {
    try {
      if (isBasicSelected) {
        basicPlanText = (await _basicController.getText()) ?? "";
      }
      if (isStandardSelected) {
        standardPlanText = (await _standardController.getText()) ?? "";
      }
      if (isAdvancedSelected) {
        advancedPlanText = (await _advancedController.getText()) ?? "";
      }
      commentText = (await _commentController.getText()) ?? "";
    } catch (e) {
      _showError("Failed to get editor content. Please try again.");
      return;
    }

    final scopeUploadModel = EditScopeApiModel(
      refId: formData['assign_id'] ?? '',
      quoteId: formData['quoteid'] ?? '',
      currency: selectedCurrencyId,
      otherCurrency: customCurrencyType,
      serviceName: selectedServiceId,
      subjectArea: selectedSubjectId,
      otherSubjectArea: customSubjectType,
      plan: [
        if (isBasicSelected) "Basic",
        if (isStandardSelected) "Standard",
        if (isAdvancedSelected) "Advanced"
      ].join(","),
      planWordCountBasic: _basicWordCountController.text,
      planWordCountStandard: _standardWordCountController.text,
      planWordCountAdvanced: _advancedWordCountController.text,
      planCommentsBasic: basicPlanText,
      planCommentsStandard: standardPlanText,
      planCommentsAdvanced: advancedPlanText,
      comments: commentText,
      feasabilityUser: selectedUserId,
    );

    try {
      final response =
          await ref.read(editScopeProvider(scopeUploadModel).future);
      if (response['status'] == true) {
        _showSuccess("Form submitted successfully!");
        if (mounted) Navigator.pop(context);
      } else {
        _showError(
            response['message'] ?? "Failed to submit form. Please try again.");
      }
    } catch (e) {
      _showError("An error occurred: ${e.toString()}");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _basicWordCountController.dispose();
    _standardWordCountController.dispose();
    _advancedWordCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: EditScopeModel(
            feasibilityUser: feasibilityUser,
            isFeasibility: isFeasibility,
            selectedCurrencyId: selectedCurrencyId,
            selectedServiceId: selectedServiceId,
            selectedSubjectId: selectedSubjectId,
            customCurrencyType: customCurrencyType,
            customSubjectType: customSubjectType,
            isBasicSelected: isBasicSelected,
            isStandardSelected: isStandardSelected,
            isAdvancedSelected: isAdvancedSelected,
            basicController: _basicController,
            standardController: _standardController,
            advancedController: _advancedController,
            commentController: _commentController,
            basicWordCountController: _basicWordCountController,
            standardWordCountController: _standardWordCountController,
            advancedWordCountController: _advancedWordCountController,
            basicWordCountText: _basicWordCountText,
            standardWordCountText: _standardWordCountText,
            advancedWordCountText: _advancedWordCountText,
            onCurrencyChanged: (value) {
              setState(() {
                selectedCurrencyId = value ?? "";
                print(selectedCurrencyId);
              });
            },
            onServiceChanged: (value) =>
                setState(() => selectedServiceId = value ?? ""),
            onSubjectChanged: (value) =>
                setState(() => selectedSubjectId = value ?? ""),
            onUserChanged: (value) =>
                setState(() => selectedUserId = value ?? ""),
            onTagChanged: (value) =>
                setState(() => selectedTagId = value ?? ""),
            onBasicChanged: (value) =>
                setState(() => isBasicSelected = value ?? false),
            onStandardChanged: (value) =>
                setState(() => isStandardSelected = value ?? false),
            onAdvancedChanged: (value) =>
                setState(() => isAdvancedSelected = value ?? false),
            onCustomCurrencyChanged: (value) =>
                setState(() => customCurrencyType = value ?? ""),
            onCustomSubjectChanged: (value) =>
                setState(() => customSubjectType = value ?? ""),
            onSubmit: _submitForm,
          ),
        ),
      ),
    );
  }
}
