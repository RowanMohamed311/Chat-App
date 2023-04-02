import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //? initiate an instance from firebase auth which is singlton object
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print(e);
      return e.message;
    }
  }

  // register
  //? FirebaseAuthException a class to handle all firebase authentication exceptions.
  Future registerWithEmailAndPassword(
      String fullname, String email, String password) async {
    try {
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        // call our database service to update the user data.
        await DatabaseService(uid: user.user!.uid)
            .updateUserData(fullname, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print(e);
      return e.message;
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailStatus('');
      await HelperFunction.saveUserNameStatus('');
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
