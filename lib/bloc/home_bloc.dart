import 'package:bloc/bloc.dart';
import 'package:chat_chat/bloc/home_event.dart';
import 'package:chat_chat/bloc/home_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadUserInfo>(_onLoadUserInfo);
    on<LoadUsers>(_onLoadUsers);
    on<LoadChatRooms>(_onLoadChatRooms);
    on<SearchUsers>(_onSearchUsers);
    on<LoadMessages>(_onLoadMessages);
    on<AddMessage>(_onSendMessage);
  }

  Future<void> _onLoadUserInfo(
      LoadUserInfo event, Emitter<HomeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("Loading user info from SharedPreferences...");
      final username = prefs.getString('username') ?? '';
      final name = prefs.getString('name') ?? '';
      final photoUrl = prefs.getString('photoUrl') ?? '';
      print(
          "Loaded user info: username=$username, name=$name, photoUrl=$photoUrl");
      emit(UserInfoLoaded(username: username, name: name, photoUrl: photoUrl));
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<HomeState> emit) async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      final currentState = state;
      Stream<List<Map<String, dynamic>>>? chatRoomsStream;
      String myUsername = currentState.myUsername;
      String myName = currentState.myName;
      String myPhotoUrl = currentState.myPhotoUrl;

      if (currentState is chatroomLoaded) {
        chatRoomsStream = currentState.mappedChatRoomsStream;
      } else if (currentState is SearchResultsUpdated) {
        chatRoomsStream = currentState.mappedChatRoomsStream;
      }

      emit(UsersLoaded(
        users,
        mappedChatRoomsStream: chatRoomsStream,
        myUsername: myUsername,
        myName: myName,
        myPhotoUrl: myPhotoUrl,
      ));
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadChatRooms(
      LoadChatRooms event, Emitter<HomeState> emit) async {
    try {
      print("Loading chat rooms for user: ${event.myUsername}");
      Stream<QuerySnapshot> chatRoomsStream = FirebaseFirestore.instance
          .collection('chatRooms')
          .where('users', arrayContains: event.myUsername)
          .snapshots();

      final mappedChatRoomsStream = chatRoomsStream.map((snapshot) {
        final chatRooms = snapshot.docs.map((doc) {
          return {
            'chatRoomId': doc.id,
            'users': doc['users'],
            'lastMessage': doc['lastMessage'] ?? '',
            'lastMessageSendTs': doc['lastMessageSendTs'],
          };
        }).toList();
        print("Firestore returned ${chatRooms.length} chat rooms");
        return chatRooms;
      });

      final currentState = state;
      emit(chatroomLoaded(
        mappedChatRoomsStream: mappedChatRoomsStream,
        myUsername: event.myUsername,
        myName: currentState.myName,
        myPhotoUrl: currentState.myPhotoUrl,
      ));
    } catch (e) {
      print("Error loading chat rooms: $e");
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<HomeState> emit) async {
    try {
      final currentState = state;
      Stream<List<Map<String, dynamic>>>? chatRoomsStream;
      String myUsername = currentState.myUsername;
      String myName = currentState.myName;
      String myPhotoUrl = currentState.myPhotoUrl;

      if (currentState is chatroomLoaded) {
        chatRoomsStream = currentState.mappedChatRoomsStream;
      } else if (currentState is UsersLoaded) {
        chatRoomsStream = currentState.mappedChatRoomsStream;
      } else if (currentState is SearchResultsUpdated) {
        chatRoomsStream = currentState.mappedChatRoomsStream;
      }

      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final allUsers = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      final filteredUsers = allUsers
          .where((user) => user['username']
              .toString()
              .toLowerCase()
              .contains(event.query.toLowerCase()))
          .toList();

      emit(SearchResultsUpdated(
        filteredUsers,
        mappedChatRoomsStream: chatRoomsStream,
        myUsername: myUsername,
        myName: myName,
        myPhotoUrl: myPhotoUrl,
      ));
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<HomeState> emit) {
    try {
      final chatRoomId = event.chatRoomId;
      Stream<QuerySnapshot> messagesStream = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots();

      Stream<List<Map<String, dynamic>>> mappedStream =
          messagesStream.map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      emit(MessagesStreamLoaded(messagesStream: mappedStream));
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  void _onSendMessage(AddMessage event, Emitter<HomeState> emit) async {
    try {
      final chatRoomId = event.chatRoomId;
      final message = event.message;
      final sendBy = event.sendBy;
      final photoUrl = event.photoUrl;

      var now = DateTime.now();
      String formatData = DateFormat("h:mma").format(now);

      Map<String, dynamic> messageInfo = {
        "message": message,
        "sendBy": sendBy,
        "ts": formatData,
        "time": FieldValue.serverTimestamp(),
        "photoUrl": photoUrl,
      };

      // Используем транзакцию для атомарного обновления
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var messageRef = FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc();

        transaction.set(messageRef, messageInfo);

        Map<String, dynamic> lastMessageInfo = {
          "lastMessage": message,
          "lastMessageSendTs": formatData,
          "lastMessageSendBy": sendBy,
          "time": FieldValue.serverTimestamp(),
        };

        var chatRoomRef =
            FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId);
        transaction.update(chatRoomRef, lastMessageInfo);
      });

      print("Message saved to Firestore: $messageInfo, chatRoomId=$chatRoomId");

      // Не эмитим MessageSent, так как поток уже обновится автоматически
      // emit(MessageSent());
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }
}
