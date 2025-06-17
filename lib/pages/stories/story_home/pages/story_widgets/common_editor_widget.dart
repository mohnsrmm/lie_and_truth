import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lie_and_truth/core/app_colors.dart';

class QuillCheckboxBuilderchild extends QuillCheckboxBuilder {
  @override
  Widget build(
      {required BuildContext context,
      required bool isChecked,
      required ValueChanged<bool> onChanged}) {
    return CircleAvatar(
      backgroundColor: AppColors.kPrimary,
      radius: 2,
    );
  }
}

class CommonTextEditorWidget extends StatelessWidget {
  final bool readOnly;

  const CommonTextEditorWidget({Key? key, this.readOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kPrimaryContainer,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: readOnly
            ? null
            : Border.all(
                color: AppColors.kPrimary,
              ),
      ),
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          readOnly: readOnly,
          padding: EdgeInsets.all(10),
          customStyles: DefaultStyles(
            color: AppColors.kPrimary,
            inlineCode: InlineCodeStyle(
              style: TextStyle(
                color: AppColors.kPrimary,
              ),
            ),
            quote: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 14,
                color: AppColors.kPrimary,
              ),
              VerticalSpacing(5, 5),
              VerticalSpacing(5, 5),
              BoxDecoration(),
            ),
            lists: DefaultListBlockStyle(
              TextStyle(
                fontSize: 14,
                color: AppColors.kPrimary,
              ),
              VerticalSpacing(5, 5),
              VerticalSpacing(5, 5),
              BoxDecoration(
                color: AppColors.kPrimary,
                border: Border.all(
                  color: AppColors.kPrimary,
                ),
              ),
              QuillCheckboxBuilderchild(),
            ),
            paragraph: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 14,
                color: AppColors.kPrimary,
              ),
              VerticalSpacing(5, 5),
              VerticalSpacing(5, 5),
              BoxDecoration(
                color: AppColors.kPrimary,
                border: Border.all(
                  color: AppColors.kPrimary,
                ),
              ),
            ),
            sizeSmall: TextStyle(
              fontSize: 14,
              color: AppColors.kPrimary,
            ),
            sizeLarge: TextStyle(
              fontSize: 18,
              color: AppColors.kPrimary,
            ),
            sizeHuge: TextStyle(
              fontSize: 24,
              color: AppColors.kPrimary,
            ),
            small: TextStyle(
              fontSize: 14,
              color: AppColors.kPrimary,
            ),
          ),
          dialogTheme: QuillDialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: AppColors.kPrimary,
              ),
            ),
            inputTextStyle: TextStyle(
              color: AppColors.kPrimary,
            ),
            dialogBackgroundColor: Colors.white,
            labelTextStyle: TextStyle(
              color: AppColors.kPrimary,
            ),
            buttonTextStyle: TextStyle(
              color: AppColors.kPrimary,
            ),
          ),
          textSelectionThemeData: TextSelectionThemeData(
            cursorColor: AppColors.kPrimary,
            selectionColor: AppColors.kPrimary.withOpacity(0.5),
            selectionHandleColor: AppColors.kPrimary,
          ),
        ),
      ),
    );
  }
}
