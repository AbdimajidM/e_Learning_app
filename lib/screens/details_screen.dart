import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/Widgets/btn_widget.dart';
import 'package:course/Widgets/build_text_field.dart';
import 'package:course/Widgets/course_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

import '../Widgets/course_content.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'my_courses_screen.dart';

class DetailsScreen extends StatefulWidget {
  final DocumentSnapshot course;
  final Function likesFn;
  final String courseId;

  const DetailsScreen({Key key, this.course, this.likesFn, this.courseId})
      : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final coursesRef = FirebaseFirestore.instance.collection('courses');
  var dio = Dio();
  User currentUser = FirebaseAuth.instance.currentUser;
  bool enrolled = false;
  bool isLoading = true;
  bool paying = false;
  bool loadingEvc = false;
  var error = '';

  final phoneNumber = TextEditingController();

  checkIfUserEnrolled() async {
    User currentUser = FirebaseAuth.instance.currentUser;
    var course = await coursesRef.doc(widget.courseId).get();
    bool isEnrolledByNotEmpty =
        course.data().entries.map((e) => e.key).toList().contains('enrolledBy');

    if (isEnrolledByNotEmpty) {
      var enrolledBy = course['enrolledBy'];
      for (var i = 0; i < enrolledBy.length; i++) {
        if (enrolledBy[i]['userId'] == currentUser.uid) {
          setState(() {
            enrolled = true;
            isLoading = false;
          });
        }
      }
    }
    setState(() {
      isLoading = false;
    });

    print('is user enrolled $enrolled');
  }

  enrollCourse() async {
    User currentUser = FirebaseAuth.instance.currentUser;
    var course = await coursesRef.doc(widget.courseId).get();

    var name = course['name'];
    var date = course['date'];
    var author = course['author'];
    var price = course['price'];
    var lectures = course['lectures'];
    var imageUrl = course['imageUrl'];

    List enrolledBy = [];

    bool checkEnrolled =
        course.data().entries.map((e) => e.key).toList().contains('enrolledBy');

    var newEnrolledUser = {
      'userId': currentUser.uid,
    };

    if (checkEnrolled) {
      enrolledBy = course['enrolledBy'];
      enrolledBy.add(newEnrolledUser);
    } else {
      enrolledBy = [newEnrolledUser];
    }

    await coursesRef.doc(widget.courseId).set({
      'name': name,
      'imageUrl': imageUrl,
      'author': author,
      'price': price,
      'date': date,
      'lectures': lectures,
      'enrolledBy': enrolledBy,
    }).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCoursesScreen(),
        ),
      );
      print(enrolled);
    });

    setState(() {});
  }

  makeEvcPlusPayment({number, price}) async {
    setState(() {
      loadingEvc = true;
    });

    var currentPhone;

    if (number != '') {
      try {
        if (number.startsWith('+252') && number.length == 13) {
          currentPhone = number.substring(1);
        } else if (number.startsWith('00252') && number.length == 14) {
          currentPhone = number.substring(2);
        } else if (number.startsWith('0252') && number.length == 13) {
          currentPhone = number.substring(1);
        } else if (number.startsWith('061') && number.length == 10) {
          currentPhone = '252' + number.substring(1);
        } else if (number.startsWith('61') && number.length == 9) {
          currentPhone = '252' + number;
        } else {
          currentPhone = number;
        }

        // request waafiPay for transaction
        var dioResponse = await dio.post('https://api.waafi.com/asm', data: {
          "schemaVersion": "1.0",
          "requestId": "10111331033", // waa Required
          "timestamp": "client_timestamp",
          "channelName": "WEB",
          "serviceName": "API_PURCHASE",
          "serviceParams": {
            "merchantUid": "M0910291", // waa Required, account jaamacadda
            "apiUserId": "1000416", // waa Required
            "apiKey": "API-675418888AHX", // waa Required
            "paymentMethod": "mwallet_account",
            "payerInfo": {
              "accountNo": currentPhone,
            }, //Meshaan cureentPhone aan dhahay waxaa laga rabaa lanbarka user-ka waan qasab
            "transactionInfo": {
              "referenceId": "12334", // waa Required
              "invoiceId": "7896504", // waa Required
              "amount":
                  price, // lacagta user-ka laga qaadaayo waye amount-ga waan qasab ani hada tusaale $2 aan dhahay lkn adi mar walbo xaalada user-ka loo fiirinaa
              "currency": "USD",
              "description": "Test USD"
            }
          }
        });

        if (dioResponse.statusCode == 200) {
          // if StatusCode == 200 it means success
          if (dioResponse.data["errorCode"] == "0") {
            // ErrorCode == "0" la mid noqdo Payment-ka waa la qaaday oo user-ka lacagta waa laga qaaday wixi intaas kasoo haro wax lacag ah lagama haayo user-ka ama pin-ka uu qalday ama cilad kale qabsatay
            enrollCourse();
          } else {
            print('Payment Error, ${dioResponse.data['responseMsg']}');
            setState(() {
              error = 'payment error';
              loadingEvc = false;
            });
          }
        }
      } catch (e) {
        setState(() {
          error = 'enter valid Number';
          loadingEvc = false;
        });
      }
    } else {
      setState(() {
        error = 'please enter the number';
        loadingEvc = false;
      });
    }
    setState(() {
      phoneNumber.text = '';
    });
  }

  @override
  void initState() {
    checkIfUserEnrolled();
    super.initState();
  }

  Widget build(BuildContext context) {
    checkIfUserEnrolled();
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                paying = false;
                phoneNumber.text = '';
                error = '';
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kBlue,
              ),
              child: Column(
                children: <Widget>[
                  // course info
                  courseInfo(
                    author: widget.course['author'],
                    name: widget.course['name'],
                    date: widget.course['date'],
                    lectures: widget.course['lectures'].length,
                    price: widget.course['price'],
                    context: context,
                  ),
                  SizedBox(height: 50),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                        ),
                        color: Colors.white,
                      ),
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(30, 30, 30, 90),
                                  child: Text("Course Content",
                                      style: kTitleTextStyle),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(30, 60, 30, 90),
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: widget.course['lectures'].length,
                                    itemBuilder: (BuildContext context, index) {
                                      final lectures =
                                          widget.course['lectures'];
                                      return CourseContent(
                                        enrolled: enrolled,
                                        number: '0${index + 1}',
                                        title: lectures[index]['title'],
                                        videoUrl: lectures[index]['videoUrl'],
                                        date: widget.course['date'],
                                        likes: lectures[index]['likes'],
                                        dislikes: lectures[index]['dislikes'],
                                        likesFn: widget.likesFn,
                                        lectureIndex: index,
                                        courseId: widget.courseId,
                                      );
                                    },
                                  ),
                                ),
                                enrolled
                                    ? SizedBox()
                                    : Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          // height: 100,
                                          width: double.infinity,
                                          child: GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                paying = true;
                                              });
                                              // enrollCourse();
                                              // makeEvcPlusPayment();
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                color: kOrangeColor,
                                              ),
                                              child: Text(
                                                "Enroll Now",
                                                style:
                                                    kSubtitleTextStyle.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          paying
              ? Positioned(
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.padding),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: contentBox(context),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: Constants.padding,
            top: Constants.avatarRadius + Constants.padding,
            right: Constants.padding,
            bottom: Constants.padding,
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 10),
                  blurRadius: 10,
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${widget.course['name']} course ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: kBoxDecorationStyle.copyWith(
                      color: Colors.white,
                      border: Border.all(
                        width: 1,
                        color: Colors.black12.withOpacity(0.005),
                      ),
                    ),
                    height: 60.0,
                    child: TextField(
                      controller: phoneNumber,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'OpenSans',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.black12,
                        ),
                        hintText: 'Enter your phone Number',
                        hintStyle: kHintTextStyle.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                error,
                style: kErrorText.copyWith(color: Colors.red),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: kOrangeColor,
                  ),
                  onPressed: () {
                    makeEvcPlusPayment(
                      number: phoneNumber.text,
                      price: widget.course['price'],
                    );
                  },
                  child: loadingEvc
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )
                      : Text(
                          "Buy now",
                          style: kTitleTextStyle.copyWith(
                            color: CupertinoColors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 2,),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(
              widget.course['imageUrl'],
            ),
          ),
        ),
      ],
    );
  }
}

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}
