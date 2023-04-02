import 'package:chat_app/pages/group_info.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupid;
  final String groupname;
  final String username;
  const ChatPage(
      {Key? key,
      required this.groupid,
      required this.groupname,
      required this.username})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  // if we need to get all the maps(fields) in a document
  Stream<QuerySnapshot>? chats;
  String admin = '';
  @override
  //! stopped at 03:45:13
  void initState() {
    // TODO: implement initState
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupid).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getChatAdmind(widget.groupid).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupname),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfo(
                    groupid: widget.groupid,
                    groupname: widget.groupname,
                    adminname: widget.username,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Send Message...',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: sendMessage(),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    messsage: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                    sentByMe:
                        widget.username == snapshot.data.docs[index]['sender'],
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messageController.text,
        'sender': widget.username,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupid, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
