import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final void Function()? onTap;
  const PostButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child:Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15)),
        child: Center(child: Icon(Icons.done),),
      ) ,
    );
  }
}
