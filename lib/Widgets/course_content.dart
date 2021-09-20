import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course/screens/video_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CourseContent extends StatefulWidget {
  final DocumentSnapshot course;
  final String number;
  final String title;
  final String videoUrl;
  final String date;
  final int likes;
  final int dislikes;
  final Function likesFn;
  final int lectureIndex;
  final String courseId;
  final bool enrolled;

  const CourseContent(
      {Key key,
      this.enrolled,
      this.number,
      this.title,
      this.videoUrl,
      this.date,
      this.likes,
      this.dislikes,
      this.course,
      this.likesFn,
      this.lectureIndex,
      this.courseId})
      : super(key: key);

  @override
  _CourseContentState createState() => _CourseContentState();
}

class _CourseContentState extends State<CourseContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        children: <Widget>[
          Text(
            widget.number,
            style: kHeadingTextStyle.copyWith(
              color: kTextColor.withOpacity(.15),
              fontSize: 32,
            ),
          ),
          SizedBox(width: 20),
          Text(
            widget.title,
            style: kSubtitleTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (widget.enrolled)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VideoDetailPage(
                      videoUrl: widget.videoUrl,
                      title: widget.title,
                      date: widget.date,
                      likes: widget.likes,
                      dislikes: widget.dislikes,
                      likesFn: widget.likesFn,
                      lectureIndex: widget.lectureIndex,
                      courseId: widget.courseId,
                    ),
                  ),
                );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.enrolled ? kBlue : Colors.grey,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
