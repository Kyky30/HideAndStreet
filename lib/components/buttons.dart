// Classe de bouton personnalisée
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:auto_size_text/auto_size_text.dart';


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
        minimumSize: Size(MediaQuery.of(context).size.width - widthMinus, 75),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: AutoSizeText(
        text,
        minFontSize: 10,
        maxFontSize: 18,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      )
    );
  }
}


class CustomButtonWithSymbol extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double scaleFactor;
  final int height;
  final int widthMinus;
  final double fontSize;
  final IconData icon;


  const CustomButtonWithSymbol({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF373967),
    this.foregroundColor = const Color(0xFF212348),
    required this.scaleFactor,
    this.height = 80,
    this.widthMinus = 30,
    this.fontSize = 20,
    this.icon = Symbols.timer_rounded,
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
        minimumSize: Size(MediaQuery.of(context).size.width - widthMinus, 75),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon,
            fill: 1,
            weight: 700,
            grade: 200,
            opticalSize: 24, // Icone du timer (horloge
            color: Colors.white,
            size: 24,),
          AutoSizeText(
            text,
            minFontSize: 10,
            maxFontSize: 18,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}