import 'package:flutter/material.dart';

class WordProvider extends ChangeNotifier {
  static const List<Map<String, String>> _wordList = [
    {
      'word': 'Aloha',
      'meaning': 'The Hawaiian word for love, affection, compassion and mercy used to define a force that holds together existence',
    },
    {
      'word': 'Gökotta',
      'meaning': 'Act of getting up early in the morning specifically to go outside to hear the birds sing.',
    },
    {
      'word': 'Flâner',
      'meaning': 'A leisurely stroll with no destination in mind to enjoy the beauty of your surroundings.',
    },
    {
      'word': 'Hanyauku',
      'meaning':
          'This describes the act of walking across warm sand on your tiptoes.',
    },
    {
      'word': 'Wabi-Sabi',
      'meaning': 'This word refers to Japanese mindset of finding beauty in something by embracing its flaws and imperfections.',
    },
    {
      'word': 'Komorebi',
      'meaning': 'A Japanese word for when the sun goes through the trees and the leaves filter the light.',
    },
    {
      'word': 'Hozho',
      'meaning': 'Working towards a sense of balance within oneself, our planet, and in life',
    },
  ];

  List<Map<String, String>> get words => _wordList;
}
