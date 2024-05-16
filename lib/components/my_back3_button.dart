import 'package:flutter/material.dart';
class MyBack3Button extends StatelessWidget {
  const MyBack3Button({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // Navigator.pop(context);
        Navigator.pushNamed(context, '/profile_page');
      },
      child: Container(
        child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.inversePrimary),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle),

      ),
    );
  }
}
