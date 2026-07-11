import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme_controller.dart';
import 'features/auth/signin.dart';
import 'features/auth/signup.dart';
import 'screens/upgrade_pro.dart';
import 'screens/meal_plan.dart';
import 'screens/progress.dart';
import 'screens/profile.dart';
import 'screens/goals_targets_screen.dart';
import 'screens/medical_reports_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/help_chat_screen.dart';
import 'screens/email_support_screen.dart';
import 'services/notification_service.dart';
import 'services/user_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/chat_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase already initialized");
  }

  tz.initializeTimeZones();
  await NotificationService.init();
  await setupFCM();
  await ThemeController.loadTheme();

  runApp(const MyNutritionCoachApp());
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission();
  print("🔔 Permission: ${settings.authorizationStatus}");

  String? token = await messaging.getToken();
  print("🔥 FCM TOKEN: $token");

  await FirebaseMessaging.instance.subscribeToTopic("all_users");
  await FirebaseMessaging.instance.subscribeToTopic("meal_reminder");
  await FirebaseMessaging.instance.subscribeToTopic("water_reminder");

  print("✅ Subscribed to topics");

  if (token != null) {
    await UserService.saveFcmToken(token); // 👈 ADD THIS
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService.showNotification(
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
      );
    }
  });

  // BACKGROUND CLICK
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print("🔔 Notification clicked (background)");

  if (message.data["type"] == "chat") {
    String expertId = message.data["senderId"];

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          expertId: expertId,
        ),
      ),
    );
  } else {
    navigatorKey.currentState?.pushNamed('/progress');
    }
  });

  // TERMINATED CLICK
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
  print("🔔 App opened from terminated state");

  if (initialMessage.data["type"] == "chat") {
    String expertId = initialMessage.data["senderId"];

    Future.delayed(const Duration(seconds: 2), () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            expertId: expertId,
          ),
        ),
      );
    });
  } else {
    navigatorKey.currentState?.pushNamed('/progress');
    }
  }
}

class MyNutritionCoachApp extends StatelessWidget {
  const MyNutritionCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,

          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'RobotoSlab',
            ),
          ),

          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'RobotoSlab',
            ),
          ),

          themeMode: themeMode,
          initialRoute: '/signin',
          routes: {
            '/signin': (_) => const SignInScreen(),
            '/signup': (_) => const SignUpScreen(),
            '/meal-plan': (_) => const MealPlanScreen(),
            '/progress': (_) => const ProgressScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/upgrade-pro': (_) => const UpgradeProScreen(),
            '/goals-targets': (_) => const GoalsTargetsScreen(),
            '/medical-reports': (context) => const MedicalReportsScreen(),
            '/reminders': (_) => const RemindersScreen(),
            '/notifications': (_) => const NotificationsScreen(),
            '/help-support': (_) => const HelpSupportScreen(),
            '/help-chat': (context) => const HelpChatScreen(),
            '/email-support': (context) => const EmailSupportScreen(),
          },
        );
      },
    );
  }
}