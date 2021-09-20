import 'package:course/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget courseInfo({String author, String name, String date, int lectures, String price, context }){
  return Padding(
    padding: EdgeInsets.only(left: 20, top: 50, right: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              child: SvgPicture.asset(
                "assets/icons/arrow-left.svg",
                color: Colors.white,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SvgPicture.asset(
              "assets/icons/more-vertical.svg",
              color: Colors.white,
            ),
          ],
        ),
        Row(
          children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               SizedBox(height: 30),
               Container(
                 decoration: BoxDecoration(
                   color: kOrangeColor,
                   borderRadius: BorderRadius.circular(5).copyWith(
                     topRight: Radius.circular(15),
                   ),
                 ),
                 padding:
                 EdgeInsets.only(left: 10, top: 5, right: 20, bottom: 5),
                 child: Text(
                   author.toUpperCase(),
                   style: TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
               SizedBox(height: 16),
               Text(
                 name,
                 style: kHeadingTextStyle,
               ),
               SizedBox(height: 16),
               Row(
                 children: <Widget>[
                   Icon(
                     Icons.access_time,
                     color: Colors.white,
                     size: 20,
                   ),
                   SizedBox(width: 5),
                   Text(
                     date,
                     style: TextStyle(color: Colors.white, fontSize: 16),
                   ),
                 ],
               ),
               SizedBox(height: 20),
               Text(
                 lectures == 1? '$lectures lecture' :'$lectures lectures',
                 style: kHeadingTextStyle.copyWith(
                     fontSize: 16, fontWeight: FontWeight.normal),
               ),
               SizedBox(height: 20,),
             ],
           ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kOrangeLightColor,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Text("\$$price",
                style: kHeadingTextStyle.copyWith(fontSize: 25,),
              ),
            )
          ],
        )
      ],
    ),
  );
}