import 'package:chat_chat/bloc/home_bloc.dart';
import 'package:chat_chat/pages/chat_page.dart';
import 'package:chat_chat/pages/home.dart';
import 'package:chat_chat/pages/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => const Onboarding(),
          '/home': (context) => const Home(),
          '/chat': (context) => _buildChatPage(context),
        },
      ),
    );
  }

  // Метод для построения ChatPage с аргументами из Navigator
  Widget _buildChatPage(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      // Если аргументы не переданы, можно вернуться на главную страницу
      return const Home();
    }

    return ChatPage(
      username: args['username'] as String,
      userprofile: args['userprofile'] as String,
      userEmail: args['userEmail'] as String,
      chatRoomId: args['chatRoomId'] as String,
    );
  }
}
