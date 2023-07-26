import 'package:find_my_roommate/widgets/customized/custom_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';
import '../../helpers/display_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = Constants.forgotPasswordScreenRoute;

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future _resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      // ignore: use_build_context_synchronously
      DisplayHelper.showSuccessMessage(context, Constants.passwordResetText);
    } on FirebaseAuthException catch (e) {
      DisplayHelper.showErrorMessage(context, e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(Constants.resetPasswordAppBarText),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Constants.resetPasswordText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline4!,
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
            child: CustomTextField(
                controller: _emailController,
                hintText: Constants.emailLabel,
                obscureText: Constants.falseText),
          ),
          MaterialButton(
            onPressed: _resetPassword,
            color: Theme.of(context).primaryColor,
            child: Text(Constants.forgotPasswordButtonText,
                style: Theme.of(context).textTheme.bodyText1!),
          ),
        ],
      ),
    );
  }
}
