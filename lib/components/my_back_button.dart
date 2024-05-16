import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});
//powrot na poprzednia strone
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/home_page');
      },
      child: Container(
        child: Icon(Icons.arrow_back,
            color: Theme.of(context).colorScheme.inversePrimary),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle),
      ),
    );
  }
}
