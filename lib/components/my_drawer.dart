import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
        //header
        DrawerHeader(child: Icon(Icons.favorite_border)),
        const SizedBox(height: 25),
        //home
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text("DODAJ OGŁOSZENIE"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
        ),
        //profile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text("PROFIL"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile_page');
              },
            ),
          ),
        //user
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.list_alt),
              title: Text("OGŁOSZENIA"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/users_page');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.person_add),
              title: Text("MOJE OGŁOSZENIA"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_page');
              },
            ),
          ),
        ],
      ),
    );
  }
}
