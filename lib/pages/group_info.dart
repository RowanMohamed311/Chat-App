import 'package:chat_app/service/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupid;
  final String groupname;
  final String adminname;
  const GroupInfo(
      {Key? key,
      required this.groupid,
      required this.groupname,
      required this.adminname})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    // TODO: implement initState
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupid)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  // String manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text('Group Info'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                //* we can not click anywhere outside the dialog
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('EXIT'),
                    content:
                        const Text('are you sure you want to Exit the group?'),
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
                          DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .toggleGroupJoin(widget.groupid,
                                  getName(widget.adminname), widget.groupname)
                              .whenComplete(
                            () {
                              Navigator.of(context)
                                  .pushReplacementNamed('home');
                            },
                          );
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
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Group: ${widget.groupname}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Admin: ${widget.adminname}'),
                    ],
                  )
                ],
              ),
            ),
            memberList()
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
                shrinkWrap: true,
              );
            } else {
              return const Center(
                child: Text('NO MEMBERS!'),
              );
            }
          } else {
            return const Center(
              child: Text('NO MEMBERS!'),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
