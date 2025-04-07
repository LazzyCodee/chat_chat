// home_event.dart
abstract class HomeEvent {}

class LoadChatRooms extends HomeEvent {
  final String myUsername;
  LoadChatRooms({required this.myUsername});
}

class SearchUsers extends HomeEvent {
  final String query;
  SearchUsers({required this.query});
}

class LoadUsers extends HomeEvent {}

class LoadUserInfo extends HomeEvent {}

class LoadMessages extends HomeEvent {
  final String chatRoomId;
  LoadMessages({required this.chatRoomId});
}

class AddMessage extends HomeEvent {
  final String chatRoomId;
  final String message;
  final String sendBy;
  final String photoUrl;

  AddMessage({
    required this.chatRoomId,
    required this.message,
    required this.sendBy,
    required this.photoUrl,
  });
}
