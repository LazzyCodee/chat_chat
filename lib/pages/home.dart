import 'package:chat_chat/bloc/home_bloc.dart';
import 'package:chat_chat/bloc/home_event.dart';
import 'package:chat_chat/bloc/home_state.dart';
import 'package:chat_chat/pages/chat_page.dart';
import 'package:chat_chat/pages/widgets/chat_room_list_tile.dart';
import 'package:chat_chat/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  String myUsername = "";

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadUserInfo());
  }

  String getChatRoomIdUsername(String a, String b) {
    List<String> users = [a, b];
    users.sort();
    return "${users[0]}_${users[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is UserInfoLoaded) {
            print("UserInfoLoaded: username=${state.myUsername}");
            setState(() {
              myUsername = state.myUsername;
            });
            context.read<HomeBloc>().add(LoadUsers());
            context
                .read<HomeBloc>()
                .add(LoadChatRooms(myUsername: state.myUsername));
          }
          if (state is HomeError) {
            print("HomeError: ${state.errorMessage}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          String myName = state.myName;
          String myPhotoUrl = state.myPhotoUrl;

          List<Map<String, dynamic>> filteredUsers = [];
          bool isSearching = searchController.text.isNotEmpty;
          if (state is SearchResultsUpdated) {
            filteredUsers = state.filteredUsers;
          }

          print(
              "Current state: $state, isSearching: $isSearching, searchText: ${searchController.text}");

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 79, 39, 197),
                  Color(0xFF6A00FF),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 45, left: 15, right: 15, bottom: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: myPhotoUrl.isNotEmpty
                            ? NetworkImage(myPhotoUrl)
                            : const AssetImage("images/image.png")
                                as ImageProvider,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Привет! $myUsername",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Хорошего дня!",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Center(
                  child: Text(
                    "Общайся и наслаждайся!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6A00FF).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            controller: searchController,
                            cursorColor: const Color(0xFF6A00FF),
                            onChanged: (query) {
                              context
                                  .read<HomeBloc>()
                                  .add(SearchUsers(query: query));
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Поиск",
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.search,
                                  color: Color(0xFF6A00FF)),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Color(0xFF6A00FF)),
                                      onPressed: () {
                                        searchController.clear();
                                        context
                                            .read<HomeBloc>()
                                            .add(SearchUsers(query: ""));
                                        context.read<HomeBloc>().add(
                                            LoadChatRooms(
                                                myUsername: myUsername));
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: isSearching
                              ? filteredUsers.isEmpty
                                  ? const Center(
                                      child: Text("Пользователи не найдены"))
                                  : ListView.builder(
                                      itemCount: filteredUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = filteredUsers[index];
                                        return GestureDetector(
                                          onTap: () {
                                            var roomId = getChatRoomIdUsername(
                                                myUsername, user['username']);
                                            Map<String, dynamic>
                                                chatRoomInfoMap = {
                                              "users": [
                                                myUsername,
                                                user['username']
                                              ],
                                              "chatRoomId": roomId,
                                              "lastMessage": "",
                                              "lastMessageSendTs":
                                                  FieldValue.serverTimestamp(),
                                            };
                                            DatabaseMethods().createChatRoom(
                                                roomId, chatRoomInfoMap);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  username: user['username'],
                                                  userprofile: user['photoUrl'],
                                                  userEmail: user['email'],
                                                  chatRoomId: roomId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            elevation: 2,
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: user['photoUrl']
                                                            .isNotEmpty &&
                                                        user['photoUrl']
                                                            .startsWith('http')
                                                    ? Image.network(
                                                        user['photoUrl'],
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          print(
                                                              "Error loading photo for ${user['username']}: $error");
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
                                                      ),
                                              ),
                                              title: Text(
                                                user['username'],
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                user['email'] ?? '',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                              : _buildChatRooms(state, myUsername),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatRooms(HomeState state, String myUsername) {
    print("Building chat rooms with state: $state");
    Stream<List<Map<String, dynamic>>>? chatRoomsStream;

    if (state is chatroomLoaded) {
      chatRoomsStream = state.mappedChatRoomsStream;
    } else if (state is UsersLoaded && state.mappedChatRoomsStream != null) {
      chatRoomsStream = state.mappedChatRoomsStream;
    } else if (state is SearchResultsUpdated &&
        state.mappedChatRoomsStream != null) {
      chatRoomsStream = state.mappedChatRoomsStream;
    }

    if (chatRoomsStream != null) {
      return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          print(
              "StreamBuilder: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("StreamBuilder error: ${snapshot.error}");
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No chat rooms found in snapshot");
            return const Center(child: Text("Нет чатов"));
          }

          final chatRooms = snapshot.data! as List<dynamic>;
          print("Found ${chatRooms.length} chat rooms in snapshot");

          List<Map<String, dynamic>> allUsers = [];
          if (state is UsersLoaded) {
            allUsers = state.users;
            print("Loaded ${allUsers.length} users: $allUsers");
          } else if (state is SearchResultsUpdated) {
            allUsers = state.filteredUsers;
          }

          return build_tile_metod(chatRooms, myUsername, allUsers);
        },
      );
    }
    print("State has no chat rooms stream: $state");
    return const Center(child: CircularProgressIndicator());
  }

  ListView build_tile_metod(List<dynamic> chatRooms, String myUsername,
      List<Map<String, dynamic>> allUsers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        var chatRoom = chatRooms[index];
        List<dynamic> users = chatRoom["users"] ?? [];
        print(
            "Chatroom ${chatRoom['chatRoomId']}: users=$users, myUsername=$myUsername");

        String? otherUser = users.length == 1 || users[0] == users[1]
            ? myUsername // Если это чат с самим собой, показываем себя
            : users.firstWhere((user) => user != myUsername,
                orElse: () => null);
        print("otherUser determined as: $otherUser");

        if (otherUser == null) {
          print("No valid otherUser found for ${chatRoom['chatRoomId']}");
          return const SizedBox.shrink();
        }

        String lastMessage = chatRoom['lastMessage'] ?? '';
        Timestamp? lastMessageSendTs;

        final rawTimestamp = chatRoom['lastMessageSendTs'];
        if (rawTimestamp is Timestamp) {
          lastMessageSendTs = rawTimestamp;
        } else if (rawTimestamp is String) {
          try {
            lastMessageSendTs =
                Timestamp.fromDate(DateTime.parse(rawTimestamp));
          } catch (e) {
            try {
              final dateFormat = DateFormat('h:mma');
              final dateTime = dateFormat.parse(rawTimestamp);
              final now = DateTime.now();
              final adjustedDateTime = DateTime(
                  now.year, now.month, now.day, dateTime.hour, dateTime.minute);
              lastMessageSendTs = Timestamp.fromDate(adjustedDateTime);
            } catch (e) {
              print(
                  "Failed to parse lastMessageSendTs string '$rawTimestamp': $e");
              lastMessageSendTs = null;
            }
          }
        } else {
          print(
              "Unexpected type for lastMessageSendTs: ${rawTimestamp.runtimeType}");
          lastMessageSendTs = null;
        }

        String photoUrl = "";
        String email = "";
        if (allUsers.isNotEmpty) {
          final user = allUsers.firstWhere(
            (user) => user['username'] == otherUser,
            orElse: () => {'photoUrl': '', 'email': ''},
          );
          photoUrl = user['photoUrl'] ?? '';
          email = user['email'] ?? '';
        }

        return ChatRoomListTile(
          username: otherUser,
          chatRoomId: chatRoom["chatRoomId"],
          lastMessage: lastMessage,
          lastMessageSendTs: lastMessageSendTs,
          photoUrl: photoUrl.isNotEmpty ? photoUrl : "images/images.jpeg",
          email: email,
        );
      },
    );
  }
}
