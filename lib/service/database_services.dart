import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // updating the user data
  Future updateUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      "fullname": fullname,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    //! A DocumentSnapshot contains data read from a document in your Cloud Firestore database. The data can be extracted with data() or get(<field>) to get a specific field.
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future creatGroup(String username, String id, String groupName) async {
    // reference for our document
    // collection -> documents -> fields
    // after executing this line of code below a specific id for the group will be generated.
    // by this way we created the group
    DocumentReference documentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$username",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // we will update the members and the group id after being created.
    await documentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$username"]),
      "groupId": documentReference.id,
    });

    // get the specific document "the document itself" of the current user from firestore.
    // then update the groups field
    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
  }

  // getting the chats (THE whole collection)
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // getting group admin
  Future getChatAdmind(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await groupCollection.doc(groupId).get();
    return documentSnapshot['admin'];
  }

  // getting group members //! this method is not a Future return type and it doesn't neet await.
  getGroupMembers(String groupid) async {
    return groupCollection.doc(groupid).snapshots();
  }

  // search
  searchByName(String groupName) {
    // return a single document or a single document snapshot.
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  // function to check the existance of a certain member in a group. -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    //doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove

    if (groups.contains('${groupId}_$groupName')) {
      await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
      });

      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName'])
      });
    } else {
      await userDocumentReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
      });

      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName'])
      });
    }
  }

  // send message
  sendMessage(String groupid, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupid).collection('messages').add(chatMessageData);
    groupCollection.doc(groupid).update(
      {
        'recentMessage': chatMessageData['message'],
        'recentMessageSender': chatMessageData['sender'],
        'recentMessageTime': chatMessageData['time'].toString()
      },
    );
  }
}
