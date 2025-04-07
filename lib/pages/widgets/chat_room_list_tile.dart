import 'package:chat_chat/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatRoomListTile extends StatelessWidget {
  final String username;
  final String chatRoomId;
  final String lastMessage;
  final Timestamp? lastMessageSendTs;
  final String photoUrl;
  final String email;

  const ChatRoomListTile({
    super.key,
    required this.username,
    required this.chatRoomId,
    required this.lastMessage,
    this.lastMessageSendTs,
    required this.photoUrl,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = "";
    if (lastMessageSendTs != null) {
      DateTime dateTime = lastMessageSendTs!.toDate();
      formattedTime =
          "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }

    print("Rendering ChatRoomListTile: username=$username, photoUrl=$photoUrl");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              username: username,
              userprofile: photoUrl,
              userEmail: email,
              chatRoomId: chatRoomId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: photoUrl.isNotEmpty && photoUrl.startsWith('http')
                ? Image.network(
                    photoUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                          "Error loading network photo for $username: $error");
                      return Image.asset(
                        "images/images.jpeg",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "images/images.jpeg",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading asset for $username: $error");
                      return const Icon(Icons.person, size: 50);
                    },
                  ),
          ),
          title: Text(
            username,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email.isNotEmpty ? email : "No email available",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (lastMessage.isNotEmpty)
                Text(
                  lastMessage,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: formattedTime.isNotEmpty
              ? Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
              : null,
        ),
      ),
    );
  }
}
