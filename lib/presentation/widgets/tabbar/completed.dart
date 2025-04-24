import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/enums.dart';
import '../../../domain/entities/document_entity.dart';
import '../empty/empty_book.dart';
import '../reader/cardBook.dart';

class CompletedBook extends StatelessWidget {
  final List<DocumentEntity> documents;

  const CompletedBook({
    Key? key,
    required this.documents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalization = AppLocalizations.of(context);
    // Lọc sách theo category Completed
    final completedBooks = documents
        .where((document) => document.category == Category.completed)
        .toList();

    if (completedBooks.isEmpty) {
      return EmptyBook(
        title: appLocalization.translate('empty.title_3'),
        buttonText: appLocalization.translate('empty.title_4'),
        onPressed: () {
          DefaultTabController.of(context).animateTo(0);
        },
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: completedBooks.length,
      itemBuilder: (context, index) {
        final document = completedBooks[index];
        return BookCard(
          document: document,
          onTap: () {
            // Điều hướng đến trang đọc với document ID
            context.push('/reader/${document.id}');
          },
        );
      },
    );
  }
}