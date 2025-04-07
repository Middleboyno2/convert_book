import 'package:flutter/material.dart';

import '../reader/cardBook.dart';

class UnreadBook extends StatelessWidget {
  const UnreadBook({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Hiển thị 2 cột
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.7
        ),
        itemCount: 5,
        itemBuilder: (context, index){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CardBook(imageUrl: '', progress: '0%',),
              Text('$index'),
            ],
          );
        }
    );
  }
}
