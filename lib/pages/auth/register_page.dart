import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/service/auth_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String fullname = '';
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
                      Image.asset('assets/wele.png', scale: 5),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        onChanged: (value) {
                          setState(() {
                            fullname = value;
                          });
                        },
                        // check the validation

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
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
                            register();
                          },
                          child: const Text(
                            'Sign Up !',
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
                          text: 'Already have an account?  ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Login here',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('login');
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

  /*
  
  (Async) means that this function is asynchronous and you might need to wait a bit to get its result.

  (Await) literally means - wait here until this function is finished and you will get its return value.

  (Future) is a type that ‘comes from the future’ and returns value from your asynchronous function. It can complete with success(.then) or with
an error(.catchError).

  (.Then((value){…})) is a callback that’s called when future completes successfully(with a value).
   */

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await authservice
          .registerWithEmailAndPassword(fullname, email, password)
          .then((value) async {
        if (value == true) {
          // saving the shared preference state.
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailStatus(email);
          await HelperFunction.saveUserNameStatus(fullname);
          //! stopped at 1:21
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
