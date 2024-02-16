// Classe de bouton personnalisée
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double scaleFactor;
  final int height;
  final int widthMinus;
  final double fontSize;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF373967),
    this.foregroundColor = const Color(0xFF212348),
    required this.scaleFactor,
    this.height = 80,
    this.widthMinus = 30,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20 * scaleFactor, // Adapter la taille du coin en fonction du facteur de zoom
            cornerSmoothing: 1,
          ),
        ),
        minimumSize: Size(MediaQuery.of(context).size.width - widthMinus, height * scaleFactor),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
    );
  }
}