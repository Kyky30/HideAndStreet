//Classe de champ de texte personnalisée
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final double scaleFactor;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final double minFontSize;
  final double maxFontSize;
  final int maxLength;
  final bool showNumber;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    required this.scaleFactor,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.minFontSize = 20,
    this.maxFontSize = 36,
    this.maxLength = 300,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeTextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
      maxLength: maxLength,

      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.grey,
          fontSize: 20 * scaleFactor,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20 ,
        ),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20 * scaleFactor,
            cornerSmoothing: 1,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}