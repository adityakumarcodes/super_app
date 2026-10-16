// ignore_for_file: non_constant_identifier_names

import 'package:milo/screens/add_task.dart';
import 'package:milo/screens/chat.dart';
import 'package:milo/screens/chat_details.dart';
import 'package:milo/atoms/constants.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/screens/calculator.dart';
import 'package:milo/screens/calender.dart';
import 'package:milo/screens/notebook.dart';
import 'package:milo/screens/settings.dart';
import 'package:milo/screens/shop.dart';
import 'package:milo/screens/social.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:milo/services/preferences_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:milo/providers/navigation_provider.dart';
import 'package:milo/providers/theme_provider.dart';
import 'package:milo/providers/word_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await PreferencesService.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider(preferences)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
        ChangeNotifierProvider(create: (_) => WordProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final showNavigationBar =
            context.watch<NavigationProvider>().view == NavigationView.navbar;

        return Scaffold(
          body: child,
          bottomNavigationBar: showNavigationBar
              ? const AppBottomNavigation()
              : null,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const MyHomePage()),
        GoRoute(
          path: '/notebook',
          builder: (context, state) => const NotebookPage(),
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
        GoRoute(path: '/shop', builder: (context, state) => const ShopPage()),
        GoRoute(
          path: '/social',
          builder: (context, state) => const SocialPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/notebook/folder/:folderId',
      builder: (context, state) {
        final folderId = int.tryParse(state.pathParameters['folderId'] ?? '');
        return NotebookPage(folderId: folderId);
      },
    ),
    GoRoute(
      path: '/notebook/note',
      builder: (context, state) => AddTaskScreen(
        noteId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
        folderId: int.tryParse(state.uri.queryParameters['folderId'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/notebook/addTask',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/chat/details',
      builder: (context, state) => ChatDetails(
        user: ChatUsers(
          name: "Jane Russel",
          location: 'London, UK',
          messageText: "Awesome Setup",
          imageURL: "assets/profiles/userImage1.png",
          time: "Now",
        ),
      ),
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => const CalculatorPage(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarPage(),
    ),
    GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
    // GoRoute(path: '/schedule', builder: (context, state) => CalendarPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      supportedLocales: const [Locale('en')],
      debugShowCheckedModeBanner: false,
      title: 'Milo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themeProvider.themeColor,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themeProvider.themeColor,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}

// class CirclePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.redAccent
//           ..strokeWidth = 2
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round;

//     var path = Path();
//     path.moveTo(0, size.height / 2);
//     path.lineTo(size.width, size.height / 2);
//     canvas.drawPath(path, paint);

//     Offset s = Offset(size.width / 2, 0);
//     Offset e = Offset(size.width / 2, size.height);
//     canvas.drawLine(s, e, paint);

//     Offset center = Offset(size.width / 2, size.height / 2);
//     canvas.drawCircle(center, 100, paint);

//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     throw UnimplementedError();
//   }
// }
