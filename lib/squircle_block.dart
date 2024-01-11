import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';


class SquircleInfoBlock extends StatelessWidget {
  final String title;
  final List<String> informationList;

  SquircleInfoBlock({required this.title, required this.informationList});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: ShapeDecoration(
        color: const Color(0xFF5E5F9F),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.white),
          ),
          SizedBox(height: 8),
          ...informationList.map(
                (info) => Text(
              info,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}