import 'package:flutter/material.dart';
import 'package:course/utils/constants.dart';

// ignore: must_be_immutable
class Header extends StatelessWidget {
  var text = 'Login';
  Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kBlue, kBlue],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100))),
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
