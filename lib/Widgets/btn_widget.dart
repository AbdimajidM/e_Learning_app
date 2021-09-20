import 'package:flutter/material.dart';
import 'package:course/utils/constants.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatelessWidget {
  var btnText = '';
  Color color;
  var onClick;


  ButtonWidget({this.btnText, this.onClick, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        margin: EdgeInsets.only(top: 5),
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: color!=null? [color,color] :[kBlue, kBlue],
              end: Alignment.centerLeft,
              begin: Alignment.centerRight),
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          btnText,
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
