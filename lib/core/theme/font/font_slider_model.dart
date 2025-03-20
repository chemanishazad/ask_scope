import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/theme/font/font_sizer.dart';

class FontSizeSlider extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeOption = ref.watch(fontSizeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Adjust Font Size",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Font size slider with preview
          Row(
            children: [
              const Icon(Icons.text_fields, size: 20, color: Colors.grey),
              Expanded(
                child: Slider(
                  value: fontSizeOption,
                  min: 8.0,
                  max: 16.0,
                  divisions: 4,
                  label: fontSizeOption.toStringAsFixed(0),
                  onChanged: (newValue) {
                    ref.read(fontSizeProvider.notifier).state = newValue;
                  },
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.grey[300],
                ),
              ),
              Text(
                "${fontSizeOption.toStringAsFixed(0)}pt",
                style: TextStyle(
                  fontSize: fontSizeOption,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Font size live preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              "This is a live preview of your font size.",
              style: TextStyle(fontSize: fontSizeOption, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
