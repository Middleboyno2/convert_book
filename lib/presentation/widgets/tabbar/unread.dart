import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/enums.dart';
import '../../../domain/entities/document_entity.dart';
import '../empty/empty_book.dart';
import '../reader/cardBook.dart';

class UnreadBook extends StatelessWidget {
  final List<DocumentEntity> documents;

  const UnreadBook({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalization = AppLocalizations.of(context);
    // Lọc sách theo category Unread
    final unreadBooks = documents
        .where((document) => document.category == Category.unread)
        .toList();

    if (unreadBooks.isEmpty) {
      return EmptyBook(
        title: appLocalization.translate('empty.title'),
        buttonText: appLocalization.translate('empty.title_2'),
        onPressed: () {
          context.push('/storage');
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
      itemCount: unreadBooks.length,
      itemBuilder: (context, index) {
        final document = unreadBooks[index];
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