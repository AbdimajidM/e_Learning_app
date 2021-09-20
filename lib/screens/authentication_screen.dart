import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/Widgets/build_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:course/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

import 'home_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLogin = true;
  bool _isLoading = false;
  var _error;
  String userName;
  String email;
  String password;
  File file;
  dynamic number;
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
    } else if (type == 'number') {
      setState(() {
        number = value;
      });
    } else {
      print('type is not recognized');
    }
  }

  Future selectFile() async {
    print('function called');
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path;
    setState(() {
      file = File(path);
    });
  }

  Future uploadFile() async {}

  Future register(String name, String password, String email, context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print('created');
      User user = result.user;
      var displayName = await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').add(
          {'userId': user.uid,'name': name, 'email': user.email});
      print('updated'); //added this line
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (e.code == 'network-request-failed') {
        setState(() {
          _error = 'network error';
          _isLoading = false;
          return;
        });
      } else {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    }
  }

  Future login(String email, String password, context) async {
    print('tried to login');

    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('tried');
      if (result != null) {
        print('checked');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e.code == 'network-request-failed') {
        setState(() {
          _error = 'network error';
          _isLoading = false;
          return;
        });
      } else {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40.0),
                      _isLogin
                          ? SizedBox(
                              height: 0,
                            )
                          : buildTextField(
                              hint: 'Enter your user name',
                              icon: Icons.person,
                              type: 'name',
                              getNumberfn: getTextFieldData,
                            ),
                      SizedBox(
                        height: 15.0,
                      ),
                      buildTextField(
                        hint: 'Enter your email',
                        icon: Icons.email,
                        type: 'email',
                        getNumberfn: getTextFieldData,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      buildTextField(
                        hint: 'Enter your password',
                        icon: Icons.lock,
                        isPassword: true,
                        type: 'password',
                        getNumberfn: getTextFieldData,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      _error != null
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _error,
                                style: kErrorText,
                              ),
                            )
                          : SizedBox(
                              height: 0,
                              width: 0,
                            ),
                      loginAndSignUpButton(),
                      // ElevatedButton(
                      //   onPressed: selectFile,
                      //   child: Text("Select File"),
                      // )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loginAndSignUpButton() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          width: double.infinity,
          child: RaisedButton(
            elevation: 5.0,
            onPressed: () async {
              if (!_isLogin) {
                if (userName != null && password != null && email != null) {
                  register(userName, password, email, context);
                } else {
                  setState(() {
                    _error = 'please fill the blank fields';
                  });
                }
              } else {
                if (email != null && password != null) {
                  login(email, password, context);
                } else {
                  setState(() {
                    _error = 'please fill the blank fields';
                  });
                }
              }
            },
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: kOrangeLightColor,
            child: _isLoading
                ? CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(kOrangeColor),
                  )
                : Text(
                    _isLogin ? 'Login' : "SIGN UP",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _isLogin
                    ? 'Don\'t have an Account? '
                    : 'Already have an Account? ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(
                      () {
                        _isLogin = !_isLogin;
                      },
                    );
                  },
                text: _isLogin ? 'Sign Up' : "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
