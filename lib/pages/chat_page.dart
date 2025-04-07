import 'package:chat_chat/bloc/home_bloc.dart';
import 'package:chat_chat/bloc/home_event.dart';
import 'package:chat_chat/bloc/home_state.dart';
import 'package:chat_chat/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String userprofile;
  final String userEmail;
  final String chatRoomId;

  const ChatPage({
    super.key,
    required this.username,
    required this.userprofile,
    required this.userEmail,
    required this.chatRoomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late HomeBloc _homeBloc;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? myUsername, myEmail, myName, myPhotoUrl;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    myUsername = await SharedPreferencesHelper().getUserNameUpper();
    myEmail = await SharedPreferencesHelper().getEmail();
    myName = await SharedPreferencesHelper().getUsername();
    myPhotoUrl = await SharedPreferencesHelper().getPhotoUrl();
    print("ChatPage: Loading messages for chatRoomId=${widget.chatRoomId}");
    _homeBloc.add(LoadMessages(chatRoomId: widget.chatRoomId));
  }

  void _sendMessage() {
    if (messageController.text.isNotEmpty &&
        myUsername != null &&
        myPhotoUrl != null) {
      _homeBloc.add(AddMessage(
        chatRoomId: widget.chatRoomId,
        message: messageController.text,
        sendBy: myUsername!,
        photoUrl: myPhotoUrl!,
      ));
      messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Widget _buildMessages(HomeState state) {
    if (state is MessagesStreamLoaded) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: state.messagesStream,
        builder: (context, snapshot) {
          print(
              "StreamBuilder: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}");
          if (snapshot.hasData) {
            print("Messages received: ${snapshot.data}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A00FF)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child:
                  Text("Нет сообщений", style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            cacheExtent: 1000.0,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              return MessageTile(
                message: messageData["message"],
                sendByMe: myUsername == messageData["sendBy"],
              );
            },
          );
        },
      );
    } else if (state is HomeError) {
      return Center(child: Text("Ошибка: ${state.errorMessage}"));
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget MessageTile({required bool sendByMe, required String message}) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color:
                  sendByMe ? const Color(0xFF3F51B5) : const Color(0xFFF5F5F5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: sendByMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF283593)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding:
                const EdgeInsets.only(top: 45, bottom: 15, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.userprofile.isNotEmpty
                        ? NetworkImage(widget.userprofile)
                        : const AssetImage("") as ImageProvider,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return _buildMessages(state);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Color(0xFF6A00FF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Введите сообщение",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A00FF),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _sendMessage,
                    child: const Icon(
                      Icons.send,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
