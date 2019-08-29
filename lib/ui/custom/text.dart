import 'package:flutter/material.dart';
import 'package:secure_upload/data/utils.dart' as utils;
import 'dart:math';



class CustomText extends StatelessWidget {
  CustomText({this.text, this.icon, this.width, this.fontSize});

  final Icon icon;
  final String text;
  final double fontSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(children: [
        Container(
          child: icon,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.grey[300],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: SizedBox(
                width: min(width, (utils.screenWidth(context) - 140)),
                child: Text(text,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}