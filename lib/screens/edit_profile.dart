import 'dart:io';
import 'dart:math';

import 'package:course/Widgets/navigation_drawer_widget.dart';
import 'package:course/api/firebase_api.dart';
import 'package:course/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'home_screen.dart';

class SettingsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Setting UI",
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User loggedInUser;
  UploadTask task;
  File file;
  bool showPassword = false;
  bool isLoading = false;
  String imageUrl;
  var userName;
  var name;
  var password;
  var email;
  var _error;
  void getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        loggedInUser = user;
        imageUrl = loggedInUser.photoURL;
      }
    } catch (e) {
      print(e);
    }
  }

  void getTextFieldData({type, value}) {
    if (type == 'name') {
      setState(() {
        userName = value;
      });
    } else if (type == 'password') {
      setState(() {
        password = value;
      });
    } else if (type == 'email') {
      setState(() {
        email = value;
      });
    } else {
      print('type is not recognized');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
        backgroundColor: kBlue,
        elevation: 3,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: kOrangeColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationDrawerWidget(),
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : file != null
                              ? FileImage(file)
                              : null,
                      backgroundColor: Colors.blue,
                      radius: 65,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: selectFile,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: kOrangeColor,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField(
                placeholder: loggedInUser.displayName,
                type: 'name',
              ),
              buildTextField(
                placeholder: "********",
                isPasswordTextField: true,
                type: 'password',
              ),
              _error!=null ? Center(child: Text(_error, style: kErrorText,)) : SizedBox(),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: deprecated_member_use
                  RaisedButton(
                      onPressed: () {
                        updateProfile(context);
                      },
                      color: kOrangeColor,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: !isLoading
                          ? Text(
                              "SAVE",
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    margin: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path;
    setState(() {
      file = File(path);
      imageUrl = null;
    });
  }

  Future updateProfile(context) async {
    try {
      setState(() {
        isLoading = true;
      });

      // when file selected
      if (file != null) {
        final fileName = loggedInUser.uid;
        final destination = 'profilesPictures/$fileName';
        task = FirebaseApi.uploadFile(destination, file);
        if (task == null) return;
        final snapshot = await task.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();

        print('Download-Link: $urlDownload');
        await loggedInUser.updatePhotoURL(urlDownload).then((value) {});
      }
      if (userName != null) {
        print('name: $userName');
        await loggedInUser.updateDisplayName(userName);
      }
      if (password != null) {
        print('password: $password');
        await loggedInUser.updatePassword(password);
      }

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {

      setState(() {
        isLoading = false;
        _error = e.message;
      });
      print(e.code);
    }
  }

  Widget buildTextField({
    String placeholder,
    bool isPasswordTextField = false,
    String type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        onChanged: (value) {
          getTextFieldData(type: type, value: value);
        },
        style: TextStyle(color: Colors.white),
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kOrangeLightColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          // suffixIcon: isPasswordTextField
          //     ? IconButton(
          //         onPressed: () {
          //           setState(() {
          //             showPassword = !showPassword;
          //           });
          //         },
          //         icon: Icon(
          //           Icons.remove_red_eye,
          //           color: Colors.white,
          //         ),
          //       )
          //     : null,
          // contentPadding: EdgeInsets.only(bottom: 3),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
