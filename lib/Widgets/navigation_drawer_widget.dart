import 'package:course/Widgets/user_header.dart';
import 'package:course/screens/authentication_screen.dart';
import 'package:course/screens/edit_profile.dart';
import 'package:course/screens/home_screen.dart';
import 'package:course/screens/my_courses_screen.dart';
import 'package:course/utils/base_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'build_menu_item.dart';

final _auth = FirebaseAuth.instance;
User loggedInUser = FirebaseAuth.instance.currentUser;

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);
  void _signOut(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthenticationScreen()),
            (Route<dynamic> route) => false);
    // runApp(MaterialApp(
    //   home: AuthenticationScreen(),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    final String name = loggedInUser.displayName;
    final String email = loggedInUser.email;
    final String urlImage = loggedInUser.photoURL;
    return Drawer(
      child: Material(
        color: Color.fromRGBO(50, 75, 205, 1),
        child: ListView(
          children: <Widget>[
            buildHeader(
              isDrawerPage: true,
              onClicked: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              ),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'My Courses',
                    icon: Icons.subject,
                    onClicked: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MyCoursesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Setting',
                    icon: Icons.settings,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white70),
                  const SizedBox(height: 16),
                  buildMenuItem(
                      text: 'Log Out',
                      icon: Icons.logout,
                      onClicked: () {
                        _auth.signOut();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => AuthenticationScreen(),
                        //   ),
                        // );
                        _signOut(context);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
