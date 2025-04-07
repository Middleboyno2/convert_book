import 'package:doantotnghiep/presentation/widgets/empty/empty_book.dart';
import 'package:doantotnghiep/presentation/widgets/reader/cardBook.dart';
import 'package:flutter/material.dart';

class CompletedBook extends StatelessWidget {
  const CompletedBook({super.key});

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
            CardBook(imageUrl: '', progress: '',),
            Text('$index'),
          ],
        );
      }
    );

  }
}
