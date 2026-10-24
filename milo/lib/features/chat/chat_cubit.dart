import 'package:flutter_bloc/flutter_bloc.dart';

class ChatState {
  const ChatState({this.selectedIndex = 0});
  final int selectedIndex;
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());
  void selectConversation(int index) => emit(ChatState(selectedIndex: index));
}
