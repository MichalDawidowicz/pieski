import 'package:flutter/material.dart';

class MyPostButton extends StatelessWidget {
  final void Function()? onTap;
  const MyPostButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child:Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        child: Center(child: Icon(Icons.done,
        color: Theme.of(context).colorScheme.primary,),),
      ) ,
    );
  }
}
