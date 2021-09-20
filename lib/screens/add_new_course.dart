import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/Widgets/btn_widget.dart';
import 'package:course/Widgets/build_text_field.dart';
import 'package:course/api/firebase_api.dart';
import 'package:course/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddNewCourse extends StatefulWidget {
  const AddNewCourse({Key key}) : super(key: key);

  @override
  _AddNewCourseState createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  final imgPicker = ImagePicker();
  CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');
  UploadTask task;
  var imgFile;
  String courseName;
  String author;
  bool isLoading = false;
  var courseId;
  var error;


  // get text field data and store the in variables
  void getTextFieldData({type, value}) {
    if (type == 'courseName') {
      setState(() {
        courseName = value;
      });
    } else if (type == 'author') {
      setState(() {
        author = value;
      });
    } else {
      print('type is not recognized');
    }
  }
  // select image from gallery
  void selectImage() async {
    var imgGallery = await imgPicker.getImage(source: ImageSource.gallery);
    setState(() {
      imgFile = File(imgGallery.path);
    });
    // Navigator.of(context).pop();
  }
//display image
  Widget displayImage() {
    if (imgFile == null) {
      return Text('No Image Selected!',
          style: kSubtitleTextStyle.copyWith(color: Colors.white));
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(imgFile),
      );
    }
  }
  // add course to the courses collection in firebase firestore
  Future<void> addCourse(courseName, author, imageUrl) {
    if(courseName!=null && author!=null)
      return courses
        .add({'name': courseName, 'author': author, 'imageUrl': imageUrl, 'date': getDate()}).then(
            (value) {
             setState(() {
               courseId = value.id;
             });
        }).catchError(
          (error) {
        print("Failed to add user: $error");
      },
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlue,
        centerTitle: true,
        title: Text("Add New Course"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(color: kBlue),
          ),
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Register Course',
                    style: kHeadingTextStyle,
                  ),
                  SizedBox(height: 30),
                  buildTextField(
                    hint: 'Enter Course Name',
                    icon: Icons.subject,
                    type: 'courseName',
                    getNumberfn: getTextFieldData,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  buildTextField(
                    hint: 'Enter author Name',
                    icon: Icons.person,
                    type: 'author',
                    getNumberfn: getTextFieldData,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      displayImage(),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: selectImage,
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Text(
                            "Select Image",
                            style: TextStyle(
                                color: kBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  isLoading ? CircularProgressIndicator() : ButtonWidget(
                    btnText:'Register',
                    onClick: () async {
                      registerCourse(context);
                    },
                    color: kOrangeColor,
                  ),
                  SizedBox(height: 10),
                  error!=null ? Text(error, style: kErrorText,) : SizedBox(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future registerCourse(context) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // when file selected
      if (imgFile != null && courseName!=null && author!=null) {
        final fileName = courseId;
        final destination = 'courseImages/$fileName';
        task = FirebaseApi.uploadFile(destination, imgFile);
        if (task == null) return;
        final snapshot = await task.whenComplete(() {});
        final fileUrl = await snapshot.ref.getDownloadURL();
        courses
            .add({'name': courseName, 'author': author, 'imageUrl': fileUrl, 'date': getDate()}).then(
                (value) {
              setState(() {
                courseId = value.id;
              });
            }).catchError(
              (error) {
            print("Failed to add user: $error");
          },
        );
      } else{
        error = 'no blank space is allowed';
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.message;
      });
    }
  }
}


getDate() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String date = formatter.format(now);
  return date;
}