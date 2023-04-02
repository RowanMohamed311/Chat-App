import 'package:chat_app/service/auth_services.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/helper_function.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  AuthService authservice = AuthService();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Chatties',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Text(
                        'Keep a Soft Touch with your Friends!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      Image.asset('assets/wele.png', scale: 4),
                      //! copywith: It allows us to obtain a copy of the existing widget but with some specified modifications. 'very clever way!!'
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        // check the validation
                        //! Take care this is gonna help us validate the input email very well.
                        validator: (value) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)
                              ? null
                              : 'please enter a valid email';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.password,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'password must be at least 6 chars.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            login();
                          },
                          child: const Text(
                            'Sign In !',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //! to make two text spans beside each other!
                      //! important to revise
                      Text.rich(
                        TextSpan(
                          text: 'Don\'t have an account?  ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Register here',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('register');
                                  }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await authservice
          .loginWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          //! a very clever way to get user data in the app
          //! to retrive the user data we have to return it in the form of snapshots
          //! we made a query inside our database service to search for our email.
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // saving the shared preference state.

          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailStatus(email);
          await HelperFunction.saveUserNameStatus(snapshot.docs[0]['fullname']);
          Navigator.of(context).pushReplacementNamed('home');
        } else {
          showSnackbar(context, Colors.red[900], value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
