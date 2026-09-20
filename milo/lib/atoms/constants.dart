import 'package:flutter/material.dart';

final List taskItems = [
  // {
  //   "time": 1741714961759,
  //   "blocks": [
  //     {
  //       "id": "bmGaOxElka",
  //       "data": {"text": "Quotes", "level": 1},
  //       "type": "header",
  //     },
  //     {
  //       "id": "dLlcGC2wba",
  //       "data": {
  //         "text":
  //             "कितने सांचो में ढल के आए हैं ,ख्वाब की तरह पल के आए हैं ,तुम सिफारिश से जहां पहुंचे हो ,हम वहां खुद ही चल के आए",
  //         "level": 4,
  //       },
  //       "type": "header",
  //     },
  //     {"id": "0_h0O2zMUQ", "data": {}, "type": "delimiter"},
  //     {
  //       "id": "vqp4Te9zE4",
  //       "data": {
  //         "text":
  //             "\"Great things happen to those who don't stop believing, trying, learning, and being grateful.\" — Roy T. Bennett",
  //         "level": 4,
  //       },
  //       "type": "header",
  //     },
  //     {"id": "EDKmE4Jb8X", "data": {}, "type": "delimiter"},
  //     {
  //       "id": "InWJWDmPu5",
  //       "data": {
  //         "text":
  //             "“Try to be a rainbow in someone else’s cloud.” — Maya Angelou",
  //         "level": 4,
  //       },
  //       "type": "header",
  //     },
  //     {"id": "IVZ4JpLO9u", "data": {}, "type": "delimiter"},
  //     {
  //       "id": "oaA3Vgsg_G",
  //       "data": {
  //         "text":
  //             "उसूलों पे जहाँ आँच आये टकराना ज़रूरी है जो ज़िन्दा हों तो फिर ज़िन्दा नज़र आना ज़रूरी है",
  //         "level": 4,
  //       },
  //       "type": "header",
  //     },
  //     {"id": "KANwFh2ddP", "data": {}, "type": "delimiter"},
  //     {
  //       "id": "O2vFZHWwSq",
  //       "data": {
  //         "text":
  //             " हज़ारों ख़्वाहिशें ऐसी कि हर ख़्वाहिश पे दम निकले बहुत निकले मिरे अरमान लेकिन फिर भी कम निकले \n\n",
  //         "level": 4,
  //       },
  //       "type": "header",
  //     },
  //   ],
  //   "version": "2.31.0-rc.7",
  // },
  {'title': 'Item 2', 'subtitle': 'Description 2'},
  {'title': 'Item 3', 'subtitle': 'Description 3'},
  {'title': 'Item 4', 'subtitle': 'Description 4'},
  {'title': 'Item 5', 'subtitle': 'Description 5'},
  {'title': 'Item 6', 'subtitle': 'Description 6'},
  {'title': 'Item 7', 'subtitle': 'Description 7'},
  {'title': 'Item 8', 'subtitle': 'Description 8'},
  {'title': 'Item 9', 'subtitle': 'Description 9'},
  {'title': 'Item 10', 'subtitle': 'Description 10'},
];

class ChatUsers {
  String name;
  String location;
  String messageText;
  String imageURL;
  String time;
  ChatUsers({
    required this.name,
    required this.location,
    required this.messageText,
    required this.imageURL,
    required this.time,
  });
}

List<ChatUsers> chatUsers = [
  ChatUsers(
    name: "Jane Russel",
    location: 'London, UK',
    messageText: "Awesome Setup",
    imageURL: "assets/profiles/userImage1.png",
    time: "Now",
  ),
  ChatUsers(
    name: "Glady's Murphy",
    location: 'London, UK',
    messageText: "That's Great",
    imageURL: "assets/profiles/userImage2.png",
    time: "Yesterday",
  ),
  ChatUsers(
    name: "Jorge Henry",
    location: 'London, UK',
    messageText: "Hey where are you?",
    imageURL: "assets/profiles/userImage3.png",
    time: "31 Mar",
  ),
  ChatUsers(
    name: "Philip Fox",
    location: 'London, UK',
    messageText: "Busy! Call me in 20 mins",
    imageURL: "assets/profiles/userImage4.png",
    time: "28 Mar",
  ),
  ChatUsers(
    name: "Debra Hawkins",
    location: 'London, UK',
    messageText: "Thankyou, It's awesome",
    imageURL: "assets/profiles/userImage5.png",
    time: "23 Mar",
  ),
  ChatUsers(
    name: "Jacob Pena",
    location: 'London, UK',
    messageText: "will update you in evening",
    imageURL: "assets/profiles/userImage6.png",
    time: "17 Mar",
  ),
  ChatUsers(
    name: "Andrey Jones",
    location: 'London, UK',
    messageText: "Can you please share the file?",
    imageURL: "assets/profiles/userImage7.png",
    time: "24 Feb",
  ),
  ChatUsers(
    name: "John Wick",
    location: 'London, UK',
    messageText: "How are you?",
    imageURL: "assets/profiles/userImage8.png",
    time: "18 Feb",
  ),
];

class FriendProvider extends ChangeNotifier {
  int friendSelectedToChat = 0;

  void setFriendSelectedToChat(int f) {
    friendSelectedToChat = f;
    notifyListeners();
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}

List<ChatMessage> messages = [
  ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
  ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
  ChatMessage(
    messageContent: "Hey Kriss, I am doing fine dude. wbu?",
    messageType: "sender",
  ),
  ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
  ChatMessage(
    messageContent: "Is there any thing wrong?",
    messageType: "sender",
  ),
  ChatMessage(messageContent: "No", messageType: "receiver"),
  ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
  ChatMessage(
    messageContent: "Hey Kriss, I am doing fine dude. wbu?",
    messageType: "sender",
  ),
  ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
  ChatMessage(
    messageContent: "Is there any thing wrong?",
    messageType: "sender",
  ),
];
