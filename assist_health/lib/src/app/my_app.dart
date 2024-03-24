import 'package:assist_health/app_config.dart';
import 'package:assist_health/src/presentation/screens/other_screens/login.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:flutter/material.dart';
import 'package:assist_health/src/presentation/screens/other_screens/welcome.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/screens/user_screens/chatbot_screen/chatbot.dart';
import 'auth_bloc/bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final config = AppConfig.of(context)!;

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      //home: ChatScreen(),
      //debugShowCheckedModeBanner: config.debugTag,
      //onGenerateRoute: AppRouter.generateRoute,

      // home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
      //   builder: (context, state) {
      //     if (state is Uninitialized) {
      //       return const WelcomeScreen();
      //     } else if (state is Unauthenticated) {
      //       return const LoginScreen();
      //     } else if (state is Authenticated) {
      //       return const UserNavBar();
      //     }

      //     return Center(child: Text('Unhandle State $state'));
      //   },
      // ),
    );
  }

  // static void initSystemDefault() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //         //statusBarColor: COLOR_CONST.STATUS_BAR,
  //         ),
  //   );
  // }
}
