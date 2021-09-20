import 'package:course/Widgets/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildHeader({
  bool isDrawerPage,
  @required VoidCallback onClicked,
}) =>
    InkWell(
      onTap: onClicked,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Row(
          children: [
            Profile(
              isDrawerPage: isDrawerPage,
              color: Colors.white
            ),
            Spacer(),
            CircleAvatar(
              radius: 24,
              backgroundColor: Color.fromRGBO(30, 60, 168, 1),
              child: Icon(Icons.cancel),
            )
          ],
        ),
      ),
    );