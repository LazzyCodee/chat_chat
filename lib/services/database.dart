// database.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addUserInfo(
      Map<String, dynamic> userInfoMap, String userId) async {
    try {
      bool exists = await checkUserExists(userId);
      if (!exists) {
        await _firestore.collection("users").doc(userId).set(userInfoMap);
        print("Пользователь добавлен: $userId");
        return true;
      } else {
        print("Пользователь уже существует: $userId");
        return false;
      }
    } catch (e) {
      print("Ошибка при добавлении пользователя: $e");
      return false;
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(userId).get();
      return doc.exists;
    } catch (e) {
      print("Ошибка проверки пользователя: $e");
      return false;
    }
  }

  Future<bool> addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageMap) async {
    try {
      await _firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("messages")
          .doc(messageId)
          .set(messageMap);
      print("Сообщение добавлено в чат $chatRoomId, messageId: $messageId");
      return true;
    } catch (e) {
      print("Ошибка при отправке сообщения: $e");
      return false;
    }
  }

  Future<bool> updateLastMessage(
      String chatRoomId, Map<String, dynamic> lastMessageInfo) async {
    try {
      lastMessageInfo['lastMessageSendTs'] = FieldValue.serverTimestamp();
      await _firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .update(lastMessageInfo);
      print(
          "Последнее сообщение обновлено в чате $chatRoomId: $lastMessageInfo");
      return true;
    } catch (e) {
      print("Ошибка при обновлении последнего сообщения: $e");
      return false;
    }
  }

  Future<bool> createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomMap) async {
    try {
      final chatRoomSnapshot =
          await _firestore.collection("chatRooms").doc(chatRoomId).get();

      if (!chatRoomSnapshot.exists) {
        chatRoomMap['lastMessageSendTs'] = FieldValue.serverTimestamp();
        await _firestore
            .collection("chatRooms")
            .doc(chatRoomId)
            .set(chatRoomMap);
        print("Создана новая чат-комната: $chatRoomId с данными: $chatRoomMap");
        return true;
      } else {
        print("Чат-комната уже существует: $chatRoomId");
        return false;
      }
    } catch (e) {
      print("Ошибка при создании чат-комнаты: $e");
      return false;
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChatRoomMessages(
      String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .limit(50)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    if (username.isEmpty) {
      return await _firestore.collection("users").get();
    }
    return await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }
}
