import 'package:flutter/material.dart';

import '../service/auth_services.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({Key? key, required this.userName, required this.email})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authservice = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.userName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColorDark),
            ),
            const SizedBox(
              height: 25,
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('home');
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading:
                  Icon(Icons.group, color: Theme.of(context).primaryColorDark),
              title: Text(
                'Groups',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
              title: Text(
                'profile',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ListTile(
              onTap: () async {
                //! remember to put it in the adhd app
                showDialog(
                  //* we can not click anywhere outside the dialog
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('LogOut'),
                      content: const Text('are you sure you want to logout?'),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red[900],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            //! a new way to do a something after a specific function is completed.
                            authservice.signOut().whenComplete(() {
                              Navigator.of(context)
                                  .pushReplacementNamed('login');
                            });
                          },
                          icon: const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app,
                  color: Theme.of(context).primaryColorDark),
              title: Text(
                'Log Out',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.account_circle,
                size: 200, color: Theme.of(context).primaryColorDark),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Full name'), Text(widget.userName)],
            ),
            const Divider(
              height: 20,
              color: Colors.black45,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Email'), Text(widget.email)],
            ),
          ],
        ),
      ),
    );
  }
}
