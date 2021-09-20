import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/screens/home_screen.dart';
import 'package:course/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'details_screen.dart';

final coursesRef = FirebaseFirestore.instance.collection('courses');

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key key}) : super(key: key);

  @override
  _MyCoursesScreenState createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: true,
        backgroundColor: kBlue,
        title: Text("My Courses"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder(
          stream: coursesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }

            User currentUser = FirebaseAuth.instance.currentUser;
            var courses = [];
            for (var i = 0; i < snapshot.data.docs.length; i++) {
              var course = snapshot.data.docs[i];
              bool isEnrolledByNotEmpty = course.data().entries.map((e) => e.key).toList().contains('enrolledBy');
              if (isEnrolledByNotEmpty) {
                var enrolledBy = course['enrolledBy'];
                for (var i = 0; i < enrolledBy.length; i++) {
                  if (enrolledBy[i]['userId'] == currentUser.uid) {
                    courses.add(course);
                    print(course);
                  } else {
                   print("no course");
                   print(currentUser.uid);
                  }
                }
              }
            }


            return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  var course = courses[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            course: course,
                            courseId: course.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: size.width / 8, vertical: 10),
                      padding: EdgeInsets.all(20),
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [kBlue, kBlue],
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              course['imageUrl'],
                            ),
                            radius: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            course['name'],
                            style: kTitleTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            course['date'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
