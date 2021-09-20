import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<User> getCurrentUser();

  Future<void> signOut();

}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User user;

  Future<String> signIn(String email, String password) async {

    user = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.email;
  }

  Future<String> signUp(String email, String password) async {
    User user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password)).user;
    return user.uid;
  }

  Future<User> getCurrentUser() async {
    user = _firebaseAuth.currentUser;
    return user;
  }
  signOut() async {
    //print("signed in user: ${authService.user}");
    await _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user =  _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }




}
