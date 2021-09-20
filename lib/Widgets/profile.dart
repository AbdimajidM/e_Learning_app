import 'package:course/screens/edit_profile.dart';
import 'package:course/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'navigation_drawer_widget.dart';

class Profile extends StatefulWidget {
  final Color color;
  final bool isDrawerPage;
  final BuildContext context;

  const Profile({
    Key key,
    this.color,
    this.isDrawerPage = false,
    this.context,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                widget.isDrawerPage ? SettingsUI() : NavigationDrawerWidget(),
          ),
        );
      },
      child: Row(
        children: [
         loggedInUser.photoURL != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(loggedInUser.photoURL),
                  radius: 25,
                )
              : CircleAvatar(
                  backgroundColor:
                      widget.isDrawerPage ? Color.fromRGBO(30, 60, 168, 1) : kBlue,
                  radius: 25,
                  child: Text(
                    '${loggedInUser.displayName[0]}',
                    style: kHeadingTextStyle.copyWith(fontSize: 20),
                  ),
                ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loggedInUser.displayName!=null ?loggedInUser.displayName : 'no name' ,
                style: kTitleTextStyle.copyWith(
                    letterSpacing: 0.8,
                    color: widget.color != null ? widget.color : kTextColor),
              ),
              Text(
                loggedInUser.email,
                style: TextStyle(
                  color: widget.color != null ? widget.color : kTextColor,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
