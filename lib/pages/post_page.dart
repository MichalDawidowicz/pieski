import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';

import '../components/my_back_button.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});
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
                  MyBackButton(),
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
