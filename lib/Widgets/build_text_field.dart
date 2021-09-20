import 'package:course/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget buildTextField(
    {String hint,
    IconData icon,
    bool isPassword = false,
    bool isSearch = false,
    String type,
    Function getNumberfn}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: 10.0),
      Container(
        margin: isSearch ? EdgeInsets.symmetric(vertical: 35) : null,
        padding: isSearch
            ? EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            : null,
        alignment: Alignment.centerLeft,
        decoration: isSearch
            ? kBoxDecorationStyle.copyWith(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF5F5F7),
                    blurRadius: 0.0,
                    offset: Offset(0, 0),
                  ),
                ],
              )
            : kBoxDecorationStyle,
        height: 60.0,
        child: TextField(
          onChanged: (value) {
            getNumberfn(type: type, value: value);
          },
          obscureText: isPassword,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
              color: isSearch ? Colors.black : Colors.white,
              fontFamily: 'OpenSans',
              fontSize: isSearch ? 18 : null),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: isSearch ? -6 : 14.0),
            prefixIcon: isSearch
                ? SvgPicture.asset(
                    "assets/icons/search.svg",
                    color: Color(0xFFA0A5BD),
                  )
                : Icon(
                    icon,
                    color: isSearch ? Colors.black : Colors.white,
                  ),
            hintText: hint,
            hintStyle: isSearch
                ? kHintTextStyle.copyWith(
                    color: Color(0xFFA0A5BD),
                  )
                : kHintTextStyle,
          ),
        ),
      ),
    ],
  );
}
