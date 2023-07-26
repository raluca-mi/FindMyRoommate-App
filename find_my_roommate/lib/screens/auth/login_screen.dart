import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';
import '../../widgets/customized/custom_button.dart';
import '../../widgets/customized/custom_field.dart';
import './forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;

  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void login() async {
    NavigatorState navigator = Navigator.of(context);
    _emailController.text = _emailController.text.trim();
    DisplayHelper.showLoadingSpinner(context);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((_) {
        navigator.pop(context);
        DisplayHelper.showSuccessMessage(context, Constants.loginSuccessText);
      });
    } on FirebaseAuthException catch (e) {
      navigator.pop(context);

      if (e.code == Constants.userNotFoundCodeText) {
        DisplayHelper.showErrorMessage(context, Constants.emailNotFoundText);
      } else if (e.code == Constants.wrongPasswordCodeText) {
        DisplayHelper.showErrorMessage(
            context, Constants.passwordIncorrectText);
      } else if (_emailController.text.isEmpty) {
        DisplayHelper.showErrorMessage(
            context, Constants.pleaseProvideEmailText);
      } else if (_passwordController.text.isEmpty) {
        DisplayHelper.showErrorMessage(
            context, Constants.pleaseProvidePasswordText);
      } else {
        DisplayHelper.showErrorMessage(context, e.message!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: mediaQuery.size.height * 0.005,
                  ),

                  //logo
                  Image.asset(Constants.logoPath,
                      height: mediaQuery.size.height * 0.3),

                  SizedBox(
                    height: mediaQuery.size.height * 0.004,
                  ),

                  //welcome back
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.size.width * 0.1),
                    child: Text(
                      Constants.welcomeBackText,
                      style: Theme.of(context).textTheme.bodyText2!,
                    ),
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.02,
                  ),

                  //email
                  CustomTextField(
                      controller: _emailController,
                      hintText: Constants.emailLabel,
                      obscureText: Constants.falseText),

                  const SizedBox(
                    height: 20,
                  ),

                  //password
                  CustomTextField(
                      controller: _passwordController,
                      hintText: Constants.passwordHintText,
                      obscureText: Constants.trueText),

                  const SizedBox(
                    height: 20,
                  ),

                  //forgot password
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.size.width * 0.1),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context)
                                  .pushNamed(ForgotPasswordScreen.routeName);
                            },
                            child: Text(Constants.forgotPasswordText,
                                style: Theme.of(context).textTheme.headline2!),
                          ),
                        ]),
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.03,
                  ),

                  //login
                  CustomButton(
                    onTap: login,
                    text: Constants.loginButtonText,
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.05,
                  ),

                  SizedBox(
                    height: mediaQuery.size.height * 0.05,
                  ),

                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Constants.notAMemberText,
                          style: Theme.of(context).textTheme.headline2!),
                      SizedBox(
                        width: mediaQuery.size.width * 0.01,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(Constants.registerNowText,
                            style: Theme.of(context).textTheme.headline3!),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
