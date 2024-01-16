import 'package:firebase_auth/firebase_auth.dart';
import 'package:rooster/util/app_mixin.dart';

class AuthHelper with AppMixin {
  AuthHelper._();
  static final AuthHelper instance = AuthHelper._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  //SIGN UP METHOD
  Future signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future<dynamic> signIn(
      {required String email, required String password}) async {
    try {
      var auth = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return auth;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN OUT METHOD
  Future signOut() async {
    await _auth.signOut();

    lp('signout');
  }
}
