import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/Widgets/build_text_field.dart';
import 'package:course/Widgets/profile.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/constants.dart';
import 'details_screen.dart';

final coursesRef = FirebaseFirestore.instance.collection('courses');

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var courses2;
  User loggedInUser;

  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
  }

  var searchedCourses;
  var searchList = [];

  Future<void> getTextFieldData({type, value}) async {
    var courses = await coursesRef.get();

    if (type == 'search') {
      setState(() {
        searchedCourses = value;
        filterSearchResults(value, courses.docs);
      });
    } else {
      print('type is not recognized');
    }
  }

  addLikesAndDislikes({String courseId, int lectureIndex, String type}) async {
    User currentUser = FirebaseAuth.instance.currentUser;
    try {
      var course = await coursesRef.doc(courseId).get();
      var name = course['name'];
      var date = course['date'];
      var imageUrl = course['imageUrl'];
      var author = course['author'];
      List lectures = [];

      for (var i = 0; i < course['lectures'].length; i++) {
        var title = course['lectures'][i]['title'];
        var videoUrl = course['lectures'][i]['videoUrl'];
        List likedBy = course['lectures'][i]['likedBy'];
        List dislikedBy = course['lectures'][i]['dislikedBy'];
        List likedUsers = [];
        List dislikedUsers = [];

        if (i == lectureIndex) {
          if (type == 'like') {
            if (likedBy != null && likedBy.length != 0) {
              for (var userId in likedBy) {
                if (userId == currentUser.uid) {
                  setState(() {
                    dislikedUsers = dislikedBy
                        .where((element) => element != currentUser.uid)
                        .toList();
                    likedUsers = likedBy
                        .where((element) => element != currentUser.uid)
                        .toList();
                  });
                } else {
                  setState(() {
                    // dislikedUsers = dislikedBy.map((element) => element==userId).toList();
                    // likedUsers = likedBy.map((element) => true).toList();
                    dislikedUsers = dislikedBy
                        .where((element) => element != currentUser.uid)
                        .toList();
                    likedUsers = likedBy.where((userId) => true).toList();
                    likedUsers.add(currentUser.uid);
                  });
                }
              }
            } else {
              likedUsers.add(currentUser.uid);
            }
            lectures.add({
              'title': title,
              'videoUrl': videoUrl,
              'likes': likedUsers.length,
              'dislikes': dislikedUsers.length,
              'likedBy': likedUsers,
              'dislikedBy': dislikedUsers
            });
          }
        }
      }

      await coursesRef.doc(courseId).set({
        'name': name,
        'imageUrl': imageUrl,
        'author': author,
        'date': date,
        'lectures': lectures
      }).then((value) {});
    } catch (e) {
      throw (e);
    }
  }

  void filterSearchResults(String query, var courses) {
    List dummySearchList = courses;
    if (query.isNotEmpty) {
      List dummyListData = [];
      print(dummySearchList);
      dummySearchList.forEach((item) {
        if (item['name'].toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        searchList = [];
        searchList = dummyListData;
      });
    } else {
      setState(() {
        searchList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, top: 25, right: 20),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Profile(
                  context: context,
                ),
                buildTextField(
                    icon: Icons.search,
                    hint: 'Search for anything',
                    isSearch: true,
                    getNumberfn: getTextFieldData,
                    type: 'search'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Courses", style: kTitleTextStyle),
                    GestureDetector(
                      onTap: () {
                        print(loggedInUser);
                      },
                      child: Text(
                        "",
                        style: kSubtitleTextStyle.copyWith(color: kOrangeColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                if (searchList != null && searchList.length != 0)
                  Expanded(
                  child: StaggeredGridView.countBuilder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    crossAxisCount: 2,
                    itemCount: searchList.length,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    itemBuilder: (context, index) {
                      DocumentSnapshot course = searchList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                course: course,
                                likesFn: addLikesAndDislikes,
                                courseId: course.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [kBlue, Colors.blue],
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
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                  ),
                ),
                if (searchList == null || searchList.length == 0)
                  StreamBuilder(
                    stream: coursesRef.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(
                          child: CircularProgressIndicator(),
                        );

                      return Expanded(
                        child: StaggeredGridView.countBuilder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          crossAxisCount: 2,
                          itemCount:
                          searchList != null && searchList.length > 0
                              ? searchList.length
                              : snapshot.data.docs.length,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          itemBuilder: (context, index) {
                            DocumentSnapshot course =
                            snapshot.data.docs[index];

                            if (snapshot.hasData)
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        course: course,
                                        likesFn: addLikesAndDislikes,
                                        courseId: course.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [kBlue, Colors.blue],
                                      end: Alignment.bottomCenter,
                                      begin: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
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
                            return Container();
                          },
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.fit(1),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
