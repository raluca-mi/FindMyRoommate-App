import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const CustomButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(mediaQuery.size.height * 0.025),
        margin: EdgeInsets.symmetric(
            horizontal: mediaQuery.size.width * 0.1,
            vertical: mediaQuery.size.height * 0.01),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(text, style: Theme.of(context).textTheme.bodyText1!),
        ),
      ),
    );
  }
}
