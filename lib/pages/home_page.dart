import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/service/auth_services.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:chat_app/widgets/group_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String email = '';
  AuthService authservice = AuthService();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  Stream? groups;
  bool _loading = false;
  String groupname = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  // String manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  gettingUserData() async {
    await HelperFunction.getUserUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunction.getUserUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    // getting the list of snapshots in our stream.
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('search');
            },
            icon: const Icon(Icons.search),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          'Groups',
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
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
              userName,
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
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group, color: Theme.of(context).primaryColor),
              title: Text(
                'Groups',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userName: userName, email: email),
                  ),
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading:
                  Icon(Icons.info, color: Theme.of(context).primaryColorDark),
              title: Text(
                'profile',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
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
                    });
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
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 20,
        child: Icon(
          Icons.add,
          size: 35,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create Group', textAlign: TextAlign.left),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _loading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      )
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            groupname = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          prefixIcon: Icon(Icons.group_add,
                              color: Theme.of(context).primaryColorDark),
                        ),
                      ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColorDark),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (groupname != "") {
                    setState(() {
                      _loading = true;
                    });
                    DatabaseService(uid: uid)
                        .creatGroup(userName, uid, groupname)
                        .whenComplete(() {
                      _loading = false;
                    });
                    Navigator.of(context).pop();
                    showSnackbar(context, Colors.green[800],
                        'Group Created Successfully.');
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColorDark),
                child: const Text('CREATE'),
              ),
            ],
          ),
        );
      },
    );
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks.
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                        groupid: getId(snapshot.data['groups'][reverseIndex]),
                        groupname:
                            getName(snapshot.data['groups'][reverseIndex]),
                        username: snapshot.data['fullname']);
                  },
                );
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                popUpDialog(context);
              },
              child: Icon(
                Icons.add_circle,
                color: Theme.of(context).primaryColorDark,
                size: 125,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'You\'ve not joined any groups, tap on the add icon to create a group or also search from top search button',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
