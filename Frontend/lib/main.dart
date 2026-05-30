import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/auth_manager.dart';
import 'providers/auth_provider.dart';
import 'providers/message_provider.dart';
import 'providers/project_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/projects/create_project_screen.dart';
import 'screens/projects/project_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.init();
  runApp(HsdApp(authProvider: authProvider));
}

class HsdApp extends StatelessWidget {
  final AuthProvider authProvider;
  const HsdApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          return MaterialApp.router(
            title: 'HSD Platform',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFCF0A2C), // Huawei kırmızısı
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFCF0A2C),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            routerConfig: _buildRouter(auth),
          );
        },
      ),
    );
  }

  GoRouter _buildRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: auth.isLoggedIn ? '/home' : '/login',
      redirect: (context, state) async {
        final loggedIn = await AuthManager.isLoggedIn();
        final onAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (!loggedIn && !onAuth) return '/login';
        if (loggedIn && onAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/projects/create',
          builder: (_, __) => const CreateProjectScreen(),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (_, state) => ProjectDetailScreen(
            projectId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
        GoRoute(
          path: '/chat/project/:projectId',
          builder: (_, state) => ChatScreen(
            projectId: int.parse(state.pathParameters['projectId']!),
            title: (state.extra as String?) ?? 'Proje Sohbeti',
          ),
        ),
        GoRoute(
          path: '/chat/direct/:userId',
          builder: (_, state) => ChatScreen(
            directUserId: int.parse(state.pathParameters['userId']!),
            title: (state.extra as String?) ?? 'Sohbet',
          ),
        ),
      ],
    );
  }
}
