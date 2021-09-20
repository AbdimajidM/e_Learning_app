import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String date;
  final int likes;
  final int dislikes;
  final DocumentSnapshot course;
  final Function likesFn;
  final int lectureIndex;
  final String courseId;

  const VideoDetailPage(
      {Key key,
      this.videoUrl,
      this.title,
      this.date,
      this.likes,
      this.dislikes,
      this.course,
      this.likesFn,
      this.lectureIndex,
      this.courseId})
      : super(key: key);
  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  User loggedInUser = FirebaseAuth.instance.currentUser;
  final coursesRef = FirebaseFirestore.instance.collection('courses');
  var lecture;
  var liked = false;
  var disliked = false;
  bool addingComment = false;
  // for video player
  VideoPlayerController _controller;
  final commentController = TextEditingController();

  getLikesAndDislikes({bool init = false}) async {
    var course = await coursesRef.doc(widget.courseId).get();
    lecture = course['lectures'][widget.lectureIndex];
    if (init) {
      var currentUser = FirebaseAuth.instance.currentUser;
      for (var userId in lecture['likedBy']) {
        if (userId == currentUser.uid) {
          setState(() {
            liked = true;
          });
        }
      }

      for (var userId in lecture['dislikedBy']) {
        if (userId == currentUser.uid) {
          setState(() {
            disliked = true;
          });
        }
      }
    }
    setState(() {});
  }

  addComment() async {
    var course = await coursesRef.doc(widget.courseId).get();
    var lecture = course['lectures'][widget.lectureIndex];
    var name = course['name'];
    var date = course['date'];
    var imageUrl = course['imageUrl'];
    var author = course['author'];
    List lectures = course['lectures'];
    List comments = lecture['comments'];

    var newComment = {
      'userName': loggedInUser.displayName,
      'imageUrl': loggedInUser.photoURL,
      'commentText': commentController.text,
    };

    if (lecture['comments'] != null) {
      lecture['comments'].add(newComment);
      commentController.clear();
    } else {
      lecture['comments'] = [newComment];
      commentController.clear();
    }
    lectures[widget.lectureIndex] = lecture;

    print(lecture);

    await coursesRef.doc(widget.courseId).set({
      'name': name,
      'imageUrl': imageUrl,
      'author': author,
      'date': date,
      'lectures': lectures
    }).then((value) {
      print("comments added");
    });
  }

  @override
  void initState() {
    getLikesAndDislikes(init: true);
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          // _controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getLikesAndDislikes();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        loggedInUser.photoURL != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(loggedInUser.photoURL),
                radius: 20,
              )
            : CircleAvatar(
                backgroundColor: kBlue,
                radius: 20,
                child: Text(
                  '${loggedInUser.displayName[0]}',
                  style: kHeadingTextStyle.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
      ],
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    bool isMuted = _controller.value.volume == 0;
    return Container(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          _controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Container(
                    color: Colors.black,
                    height: 220,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? null
                                    : Icons.play_arrow,
                                size: 50,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          bottom: 20,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.setVolume(isMuted ? 1 : 0);
                                  });
                                },
                                child: Icon(
                                  isMuted ? Icons.volume_mute : Icons.volume_up,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 220,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    ],
                  ),
                ),
          Expanded(
            child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 28,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.date,
                        style: TextStyle(
                          color: Colors.orange.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: " Write Comment",
                                    hintStyle: kHintTextStyle.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: IconButton(
                                  onPressed: () {
                                    addComment();
                                  },
                                  icon: Icon(Icons.send),
                                  color: kBlue,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      StreamBuilder(
                        stream: coursesRef.doc(widget.courseId).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var lecture =
                                snapshot.data['lectures'][widget.lectureIndex];
                            var comments = lecture['comments'];

                            List<Widget> commentTiles = [];
                            if (comments != null) {
                              for (var comment in comments) {
                                commentTiles.add(buildComment(comment));
                              }
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Column(
                                children: commentTiles,
                              ),
                            );
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget buildComment(comment) {
  return ListTile(
    leading: comment['imageUrl'] != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(comment['imageUrl']),
            radius: 20,
          )
        : CircleAvatar(
            backgroundColor: kBlue,
            radius: 20,
            child: Text(
              comment['userName'] != null ? comment['userName'][0] : 'no',
              style: kHeadingTextStyle.copyWith(fontSize: 15),
            ),
          ),
    title: comment['userName'] != null
        ? Text(
            comment['userName'],
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          )
        : Text('no'),
    subtitle: comment['commentText'] != null
        ? Text(
            comment['commentText'],
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        : Text("no"),
  );
}
