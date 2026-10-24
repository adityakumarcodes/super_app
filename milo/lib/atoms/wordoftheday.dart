import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/features/home/word_cubit.dart';

class WordOfTheDay extends StatefulWidget {
  const WordOfTheDay({super.key});

  @override
  State<WordOfTheDay> createState() => _WordOfTheDayState();
}

class _WordOfTheDayState extends State<WordOfTheDay> {
  int currentWordIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordCubit, WordState>(
      builder: (context, wordState) {
        final data = wordState.words;
        final index = data.isEmpty ? 0 : currentWordIndex % data.length;
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: GestureDetector(
            onTap: data.isEmpty
                ? null
                : () => setState(
                    () => currentWordIndex = (index + 1) % data.length,
                  ),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: const DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1536147116438-62679a5e01f2?auto=format&fit=crop&q=50&w=600',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(0, 0, 0, 0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: wordState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : wordState.error != null
                    ? Text(
                        wordState.error!,
                        style: const TextStyle(color: Colors.white),
                      )
                    : data.isEmpty
                    ? const Text(
                        'No words available',
                        style: TextStyle(color: Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            data[index]['word']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dancingScript(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data[index]['meaning']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
