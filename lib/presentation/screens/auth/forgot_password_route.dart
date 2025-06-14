import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/presentation/screens/auth/forgot_password_screen.dart';


@RoutePage()
class ForgotPasswordRoute extends StatelessWidget {
  const ForgotPasswordRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const ForgotPasswordScreen();
  }
}
