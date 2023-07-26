import 'package:flutter/material.dart';

class CustomEditField extends StatelessWidget {
  final bool isInEditMode;
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomEditField(
      {this.controller,
      this.isInEditMode = true,
      this.hintText,
      this.validator,
      this.prefixIcon,
      this.keyboardType = TextInputType.text,
      this.maxLines,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
          enabled: isInEditMode,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).backgroundColor),
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: prefixIcon,
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
            fillColor: Colors.grey[200],
            filled: true,
            hintText: hintText,
          ),
          textInputAction: TextInputAction.next,
          validator: validator),
    );
  }
}
