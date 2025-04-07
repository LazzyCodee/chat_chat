abstract class HomeState {
  final String myUsername;
  final String myName;
  final String myPhotoUrl;

  HomeState({
    this.myUsername = '',
    this.myName = '',
    this.myPhotoUrl = '',
  });
}

class HomeInitial extends HomeState {
  HomeInitial() : super();
}

class UserInfoLoaded extends HomeState {
  UserInfoLoaded({
    required String username,
    required String name,
    required String photoUrl,
  }) : super(myUsername: username, myName: name, myPhotoUrl: photoUrl);
}

class UsersLoaded extends HomeState {
  final List<Map<String, dynamic>> users;
  final Stream<List<Map<String, dynamic>>>? mappedChatRoomsStream;

  UsersLoaded(
    this.users, {
    this.mappedChatRoomsStream,
    String myUsername = '',
    String myName = '',
    String myPhotoUrl = '',
  }) : super(myUsername: myUsername, myName: myName, myPhotoUrl: myPhotoUrl);
}

class chatroomLoaded extends HomeState {
  final Stream<List<Map<String, dynamic>>> mappedChatRoomsStream;

  chatroomLoaded({
    required this.mappedChatRoomsStream,
    String myUsername = '',
    String myName = '',
    String myPhotoUrl = '',
  }) : super(myUsername: myUsername, myName: myName, myPhotoUrl: myPhotoUrl);
}

class SearchResultsUpdated extends HomeState {
  final List<Map<String, dynamic>> filteredUsers;
  final Stream<List<Map<String, dynamic>>>? mappedChatRoomsStream;

  SearchResultsUpdated(
    this.filteredUsers, {
    this.mappedChatRoomsStream,
    String myUsername = '',
    String myName = '',
    String myPhotoUrl = '',
  }) : super(myUsername: myUsername, myName: myName, myPhotoUrl: myPhotoUrl);
}

class HomeError extends HomeState {
  final String errorMessage;

  HomeError({
    required this.errorMessage,
    String myUsername = '',
    String myName = '',
    String myPhotoUrl = '',
  }) : super(myUsername: myUsername, myName: myName, myPhotoUrl: myPhotoUrl);
}

class MessagesStreamLoaded extends HomeState {
  final Stream<List<Map<String, dynamic>>> messagesStream;
  MessagesStreamLoaded({required this.messagesStream});
}

class MessageSent extends HomeState {}
