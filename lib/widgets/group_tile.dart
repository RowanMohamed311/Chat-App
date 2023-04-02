import 'package:chat_app/pages/chat_page.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String username;
  final String groupid;
  final String groupname;
  GroupTile(
      {Key? key,
      required this.groupid,
      required this.groupname,
      required this.username})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              groupid: widget.groupid,
              groupname: widget.groupname,
              username: widget.username,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Text(widget.groupname.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center),
          ),
          title: Text(
            widget.groupname,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Join the conversation as ${widget.username}"),
        ),
      ),
    );
  }
}
