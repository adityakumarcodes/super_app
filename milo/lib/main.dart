// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milo/atoms/constants.dart';
import 'package:milo/atoms/folder_list.dart';
import 'package:milo/services/app_config.dart';
import 'package:milo/models/task.dart';
import 'package:milo/providers/auth_provider.dart';
import 'package:milo/providers/navigation_provider.dart';
import 'package:milo/providers/task_provider.dart';
import 'package:milo/providers/theme_provider.dart';
import 'package:milo/providers/word_provider.dart';
import 'package:milo/screens/add_task.dart';
import 'package:milo/screens/calculator.dart';
import 'package:milo/screens/calender.dart';
import 'package:milo/screens/chat.dart';
import 'package:milo/screens/chat_details.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/screens/login.dart';
import 'package:milo/screens/note_details.dart';
import 'package:milo/screens/notebook.dart';
import 'package:milo/screens/settings.dart';
import 'package:milo/screens/shop.dart';
import 'package:milo/screens/social.dart';
import 'package:milo/services/preferences_service.dart';
import 'package:provider/provider.dart';

import 'screens/calculator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBetterAuth.initialize(url: AppConfig.authBaseUrl);

  final preferences = await PreferencesService.load();
  final authProvider = AuthProvider(FlutterBetterAuth.client);
  final router = _createRouter(authProvider);
  unawaited(authProvider.restoreSession());

  runApp(
    BetterAuthProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => FriendProvider()),
          ChangeNotifierProvider(
            create: (_) => NavigationProvider(preferences),
          ),
          ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
          ChangeNotifierProvider(create: (_) => WordProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: MyApp(router: router),
      ),
    ),
  );
}

GoRouter _createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLogin = state.matchedLocation == '/login';
      final isAuthLoading = state.matchedLocation == '/auth-loading';

      if (authProvider.isRestoring) {
        return isAuthLoading ? null : '/auth-loading';
      }
      if (!authProvider.isAuthenticated) return isLogin ? null : '/login';
      return isLogin || isAuthLoading ? '/' : null;
    },
    routes: [
      GoRoute(
        path: '/auth-loading',
        builder: (context, state) => const AuthLoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
        path: '/notebook/folder/:name',
        builder: (context, state) {
          final folderName = state.pathParameters['name']!;
          return FolderList(folderName: folderName);
        },
      ),
      GoRoute(
        path: '/notebook/note/:id',
        builder: (context, state) {
          final task = state.extra;
          if (task is! Task) return const _MissingNotePage();

          return NoteDetailsPage(task: task);
        },
      ),
      GoRoute(
        path: '/notebook/addTask',
        builder: (context, state) => AddTaskScreen(),
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
      // GoRoute(
      //   path: '/calculator',
      //   builder: (context, state) => const CalculatorPage(),
      // ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
      // GoRoute(path: '/schedule', builder: (context, state) => CalendarPage()),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
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
      routerConfig: router,
    );
  }
}

class _MissingNotePage extends StatelessWidget {
  const _MissingNotePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Open this note from the notes list so its details can load.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/notebook'),
                child: const Text('Back to notes'),
              ),
            ],
          ),
        ),
      ),
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
