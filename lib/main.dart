import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/route/routes.dart';
import 'package:loop/core/theme/font/font_sizer.dart';
import 'package:loop/core/theme/theme.dart';
import 'package:loop/core/utils/service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // NotificationServices.navigatorKey = navigatorKey;
  // await NotificationServices.init();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ApiMaster.loadToken();

  // final deviceToken = await NotificationServices.getDeviceToken();
  // print('Device Token: $deviceToken');

  // final serverAccessToken = await NotificationServices.sendNotification();
  // print('Server Access Token: $serverAccessToken');

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Career panel',
          // themeMode: ThemeMode.system,
          theme: lightTheme(fontSize),
          // darkTheme: darkTheme(fontSize),
          initialRoute: '/',
          routes: AppRoutes.routes,
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}
