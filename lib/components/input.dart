//Classe de champ de texte personnalisée
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final double scaleFactor;
  final void Function(String)? onChanged;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    required this.scaleFactor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: 20 * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 20 * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.grey,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20 * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
          vertical: 20 * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
        ),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20 * scaleFactor, // Adapter la taille du coin en fonction du facteur de zoom
            cornerSmoothing: 1,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}