// ignore_for_file: non_constant_identifier_names

import 'package:milo/screens/add_task.dart';
import 'package:milo/screens/calender.dart';
import 'package:milo/screens/chat.dart';
import 'package:milo/screens/chat_details.dart';
import 'package:milo/atoms/constants.dart';
import 'package:milo/atoms/folder_list.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/screens/calculator.dart';
import 'package:milo/screens/notebook.dart';
import 'package:milo/screens/settings.dart';
import 'package:milo/screens/shop.dart';
import 'package:milo/screens/social.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:milo/providers/theme_provider.dart';
import 'package:milo/providers/word_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://afchbjopvwwocaqtwgxo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmY2hiam9wdnd3b2NhcXR3Z3hvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1OTUwNTksImV4cCI6MjA0OTE3MTA1OX0.XJsAYSp6chxfhi61kpGc8v9wz2B3ppCF7NcqhBDUwVA',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    GoRoute(path: '/', builder: (context, state) => MyHomePage()),
    GoRoute(path: '/notebook', builder: (context, state) => NotebookPage()),
    GoRoute(
      path: '/notebook/folder/:name',
      builder: (context, state) {
        final folderName = state.pathParameters['name']!;
        return FolderList(folderName: folderName);
      },
    ),
    GoRoute(
      path: '/notebook/addTask',
      builder: (context, state) => AddTaskScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => ChatPage()),
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
    GoRoute(path: '/social', builder: (context, state) => SocialPage()),
    GoRoute(path: '/shop', builder: (context, state) => ShopPage()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
    GoRoute(path: '/calendar', builder: (context, state) => CalendarPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aloha',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themeProvider.themeColor,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
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
