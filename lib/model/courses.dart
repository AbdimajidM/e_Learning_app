class Course {
  final String name;
  final String image;
  final List lectures;
  final String author;
  final String date;
  Course({this.name, this.image, this.lectures, this.date, this.author});
}

class Lecture {
  final title;
  final video;
  Lecture({this.title, this.video});
}

List<Lecture> marketingLectures = [
  Lecture(
    title: 'Welcome to marketing',
    video: 'daldajdl',
  ),
  Lecture(title: 'First lesson of marketig', video: 'huuhaa'),
  Lecture(
    title: 'Welcome to marketing',
    video: 'daldajdl',
  ),
  Lecture(title: 'First lesson of marketig', video: 'huuhaa')
];

List<Lecture> uxDesignLectures = [
  Lecture(title: 'Welcome to marketing', video: 'daldajdl'),
  Lecture(title: 'First lesson of marketig', video: 'huuhaa')
];

List<Lecture> photographyLectures = [
  Lecture(title: 'Welcome to marketing', video: 'daldajdl'),
  Lecture(title: 'First lesson of marketig', video: 'huuhaa')
];

List<Lecture> businessLectures = [
  Lecture(title: 'Welcome to marketing', video: 'daldajdl'),
  Lecture(title: 'First lesson of marketig', video: 'huuhaa')
];

List<Course> courses = [
  Course(
    name: 'Marketing',
    image: "assets/images/marketing.png",
    lectures: marketingLectures,
    author: 'Damlad Ahmed',
    date: '14 june 2021',
  ),
  Course(
    name: 'Ux Design',
    image: "assets/images/marketing.png",
    lectures: uxDesignLectures,
    author: 'Xasan Ahmed',
    date: '14 june 2021',
  ),
  Course(
    name: 'Photography',
    image: "assets/images/photography.png",
    lectures: photographyLectures,
    author: 'Damlad Ahmed',
    date: '14 june 2021',
  ),
  Course(
    name: "Business",
    image: "assets/images/business.png",
    lectures: businessLectures,
    author: 'Damlad Ahmed',
    date: '14 june 2021',
  )
];
