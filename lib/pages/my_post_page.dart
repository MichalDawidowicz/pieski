import 'package:flutter/material.dart';

import '../components/my_back3_button.dart';

class MyPostPage extends StatelessWidget {
  const MyPostPage({super.key});
  // Future String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyBack3Button(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.settings),)
                ],
              ),
            ),
            Text("TODO")

            //Wyswietlanie danych o poscie
          ],
        ),
      ),
    );
  }
}
