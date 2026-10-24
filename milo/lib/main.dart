// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milo/atoms/folder_list.dart';
import 'package:milo/core/cubit_router_refresh.dart';
import 'package:milo/features/auth/auth_cubit.dart';
import 'package:milo/features/chat/chat_cubit.dart';
import 'package:milo/features/home/word_cubit.dart';
import 'package:milo/features/notes/task_cubit.dart';
import 'package:milo/features/settings/navigation_cubit.dart';
import 'package:milo/features/settings/theme_cubit.dart';
import 'package:milo/core/app_config.dart';
import 'package:milo/core/task.dart';
import 'package:milo/screens/add_task.dart';
import 'package:milo/screens/calender.dart';
import 'package:milo/screens/chat.dart';
import 'package:milo/screens/chat_details.dart';
import 'package:milo/screens/error404.dart';
import 'package:milo/screens/home.dart';
import 'package:milo/screens/login.dart';
import 'package:milo/screens/note_details.dart';
import 'package:milo/screens/notebook.dart';
import 'package:milo/screens/settings.dart';
import 'package:milo/screens/shop.dart';
import 'package:milo/screens/social.dart';
import 'package:milo/core/preferences_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBetterAuth.initialize(url: AppConfig.authBaseUrl);

  final preferences = await PreferencesService.load();
  final authCubit = AuthCubit(FlutterBetterAuth.client);
  final router = _createRouter(authCubit);
  unawaited(authCubit.restoreSession());

  runApp(
    BetterAuthProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider(create: (_) => ChatCubit()),
          BlocProvider(create: (_) => NavigationCubit(preferences)),
          BlocProvider(create: (_) => ThemeCubit(preferences)),
          BlocProvider(create: (_) => WordCubit()),
          BlocProvider(create: (_) => TaskCubit()),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.isAuthenticated && !current.isAuthenticated,
          listener: (context, _) => context.read<TaskCubit>().clear(),
          child: MyApp(router: router),
        ),
      ),
    ),
  );
}

GoRouter _createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: CubitRouterRefresh(authCubit),
    errorBuilder: (context, state) => const Error404Screen(),
    redirect: (context, state) {
      final isLogin = state.matchedLocation == '/login';
      final isAuthLoading = state.matchedLocation == '/auth-loading';

      if (authCubit.state.isRestoring) {
        return isAuthLoading ? null : '/auth-loading';
      }
      if (!authCubit.state.isAuthenticated) return isLogin ? null : '/login';
      return isLogin || isAuthLoading ? '/' : null;
    },
    routes: [
      GoRoute(
        path: '/auth-loading',
        builder: (context, state) => AuthLoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          final showNavigationBar =
              context.select((NavigationCubit cubit) => cubit.state.view) ==
              NavigationView.navbar;

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
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const _MissingNotePage();

          final task = state.extra;
          return NoteDetailsPage(
            noteId: id,
            initialTask: task is Task ? task : null,
          );
        },
      ),
      GoRoute(
        path: '/notebook/addTask',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/notebook/note/:id/edit',
        redirect: (context, state) => state.extra is Task
            ? null
            : '/notebook/note/${state.pathParameters['id']}',
        builder: (context, state) => AddTaskScreen(note: state.extra as Task),
      ),
      GoRoute(
        path: '/chat/details',
        builder: (context, state) => const ChatDetails(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Milo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themeState.color,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themeState.color,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      themeMode: themeState.mode,
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
                'This note link is not valid.',
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
