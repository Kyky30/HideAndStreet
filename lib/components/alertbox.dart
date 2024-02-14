// Classe de boîte d'alerte personnalisée
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:hide_and_street/components/buttons.dart';

class CustomAlertDialog1 extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final Function onPressed;
  final double scaleFactor;

  const CustomAlertDialog1({
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onPressed,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: const Color(0xFF212348),
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          color: const Color(0xFF212348),
        ),
      ),
      actions: <Widget>[
        CustomButton(
          text: buttonText,
          onPressed: () => onPressed(),
          backgroundColor: const Color(0xFF373967),
          scaleFactor: scaleFactor,
        ),
      ],
    );
  }
}

// Classe de boîte d'alerte personnalisée
class CustomAlertDialog2 extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText1;
  final String buttonText2;
  final Function onPressed1;
  final Function onPressed2;
  final double scaleFactor;

  const CustomAlertDialog2({
    required this.title,
    required this.content,
    required this.buttonText1,
    required this.buttonText2,
    required this.onPressed1,
    required this.onPressed2,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: const Color(0xFF212348),
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          color: const Color(0xFF212348),
        ),
      ),
      actions: <Widget>[
        CustomButton(
          text: buttonText1,
          onPressed: () => onPressed1(),
          backgroundColor: const Color(0xFF373967),
          scaleFactor: scaleFactor,
        ),
        SizedBox(height: 10 * scaleFactor),
        CustomButton(
          text: buttonText2,
          onPressed: () => onPressed2(),
          backgroundColor: const Color(0xFF373967),
          scaleFactor: scaleFactor,
        ),
      ],
    );
  }
}


