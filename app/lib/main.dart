import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/forgot_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Electrolytes App',
        builder: (context, child) =>
            FAnimatedTheme(data: FThemes.zinc.light, child: child!),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

// Authentication wrapper to handle login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // For now, always show login page first
    // In a real app, you might want to check for stored tokens
    return const LoginPage();
  }
}

// Home page for both authenticated and guest users
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return FScaffold(
      header: FHeader(
        title: const Text('Electrolytes App'),
        actions: [
          if (authService.isAuthenticated)
            FButton(
              onPress: _logout,
              style: FButtonStyle.ghost,
              child: const Text('Logout'),
            )
          else
            FButton(
              onPress: () => Navigator.of(context).pushNamed('/login'),
              style: FButtonStyle.ghost,
              child: const Text('Login'),
            ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authService.isAuthenticated && authService.username != null)
              Text(
                'Welcome back, ${authService.username}!',
                style: Theme.of(context).textTheme.headlineSmall,
              )
            else
              const Text(
                'Welcome, Guest!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      authService.isAuthenticated
                          ? 'Authentication system is working!'
                          : 'Welcome to Electrolytes App!',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authService.isAuthenticated
                          ? 'You are successfully logged in.'
                          : 'You can use the app as a guest or login for additional features.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (authService.isAuthenticated) ...[
                      FButton(
                        onPress: () async {
                          final result = await authService.getCurrentUser();
                          if (result['success'] && mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => FAlertDialog(
                                title: const Text('User Information'),
                                body: Text('Username: ${result['user']['username']}\nEmail: ${result['user']['email'] ?? 'Not provided'}\nRole: ${result['user']['role']}\nStatus: ${result['user']['status']}'),
                                actions: [
                                  FButton(
                                    style: FButtonStyle.primary,
                                    onPress: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: FButtonStyle.primary,
                        child: const Text('Get User Info'),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FButton(
                            onPress: () => Navigator.of(context).pushNamed('/login'),
                            style: FButtonStyle.primary,
                            child: const Text('Login'),
                          ),
                          const SizedBox(width: 16),
                          FButton(
                            onPress: () => Navigator.of(context).pushNamed('/signup'),
                            style: FButtonStyle.outline,
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
