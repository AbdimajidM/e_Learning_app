import 'package:flutter/material.dart';

// Colors
const Color kTextColor = Color(0xFF0D1333);
const Color kOrangeColor = Color(0xffF5591F);
const Color kBestSellerColor = Color(0xFF3AB8D8);
const Color kBlue = Color.fromRGBO(50, 75, 205, 1);
const Color kGreenColor = Color(0xFF49CC96);
const Color kOrangeLightColor = Color(0xffF2861E);

// My Text Styles
const kHeadingTextStyle = TextStyle(
  fontSize: 28,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
const kSubheadingTextStyle = TextStyle(
  fontSize: 24,
  color: Color(0xFF61688B),
  height: 2,
);

const kTitleTextStyle = TextStyle(
  fontSize: 20,
  color: kTextColor,
  fontWeight: FontWeight.bold,
);

const kSubtitleTextStyle = TextStyle(
  fontSize: 18,
  color: kTextColor,
  // fontWeight: FontWeight.bold,
);

// for login and signup

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final kErrorText = TextStyle(
  color: Colors.white,
);
