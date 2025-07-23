// lib/widgets/tafseer_text_widget.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';

class TafseerTextWidget extends StatelessWidget {
  final String text;
  final Map<String, String>? footnotes;

  const TafseerTextWidget({super.key, required this.text, this.footnotes});

  // Text Sanitization Method
  String _sanitizeText(String input) {
    String sanitized = input;

    // Replace common "look-alike" parentheses and digits with ASCII ones
    sanitized = sanitized.replaceAll('（', '('); // Full-width parenthesis
    sanitized = sanitized.replaceAll('）', ')'); // Full-width parenthesis
    sanitized = sanitized.replaceAll('［', '['); // Full-width bracket
    sanitized = sanitized.replaceAll('］', ']'); // Full-width bracket
    sanitized = sanitized.replaceAll('＾', '^'); // Full-width caret
    sanitized = sanitized.replaceAll('٠', '0'); // Arabic-Indic digit zero
    sanitized = sanitized.replaceAll('١', '1'); // Arabic-Indic digit one
    sanitized = sanitized.replaceAll('٢', '2'); // Arabic-Indic digit two
    sanitized = sanitized.replaceAll('٣', '3'); // Arabic-Indic digit three
    sanitized = sanitized.replaceAll('٤', '4'); // Arabic-Indic digit four
    sanitized = sanitized.replaceAll('٥', '5'); // Arabic-Indic digit five
    sanitized = sanitized.replaceAll('٦', '6'); // Arabic-Indic digit six
    sanitized = sanitized.replaceAll('٧', '7'); // Arabic-Indic digit seven
    sanitized = sanitized.replaceAll('٨', '8'); // Arabic-Indic digit eight
    sanitized = sanitized.replaceAll('٩', '9'); // Arabic-Indic digit nine

    // Remove zero-width spaces or non-breaking spaces if they caused issues
    sanitized = sanitized.replaceAll('\u200B', ''); // Zero Width Space
    sanitized = sanitized.replaceAll(
      '\u00A0',
      ' ',
    ); // Non-breaking space to regular space

    return sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final String processedText = _sanitizeText(text);

    final RegExp footnoteRegex = RegExp(
      r'\(\((\d+)\)\)',
    ); // Matches e.g., ((1))

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    processedText.replaceAllMapped(footnoteRegex, (Match match) {
      // Add the text before the current footnote marker
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: processedText.substring(lastMatchEnd, match.start),
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.darkGrey,
              height: 1.5,
            ),
          ),
        );
      }

      // Get the footnote number (e.g., '1', '2')
      final String footnoteNumber = match.group(1)!;
      final String? footnoteContent = footnotes?[footnoteNumber];

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () {
              if (footnoteContent != null) {
                TafseerTextWidget._showFootnoteDialog(
                  context,
                  footnoteNumber,
                  footnoteContent,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Footnote $footnoteNumber content not found in data.',
                    ),
                  ),
                );
              }
            },
            child: Transform.translate(
              offset: const Offset(
                0.0,
                -AppDimens.paddingSmall / 2,
              ), // Adjust vertical offset for superscript
              child: Text(
                footnoteNumber, // Display just the number
                style: AppTextStyles.captionText.copyWith(
                  // Smaller font size
                  color: AppColors.royalBlue, // Highlight footnote numbers
                  fontWeight: FontWeight.bold,
                  backgroundColor: AppColors.royalBlue.withOpacity(
                    0.1,
                  ), // Visible tap area
                  decoration: TextDecoration.underline,
                  fontSize: AppTextStyles.captionText.fontSize! * 0.9,
                ),
              ),
            ),
          ),
          alignment: PlaceholderAlignment.top,
          baseline: TextBaseline.alphabetic,
        ),
      );

      lastMatchEnd = match.end;
      return '';
    });

    // Add any remaining text after the last footnote marker
    if (lastMatchEnd < processedText.length) {
      spans.add(
        TextSpan(
          text: processedText.substring(lastMatchEnd),
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.darkGrey,
            height: 1.5,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    );
  }

  static void _showFootnoteDialog(
    BuildContext context,
    String number,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          ),
          title: Text(
            'Footnote [$number]',
            style: AppTextStyles.heading3.copyWith(color: AppColors.royalBlue),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.darkGrey),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Close',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
