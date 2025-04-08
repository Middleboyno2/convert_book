import 'package:flutter/material.dart';
import '../../../config/colors/kcolor.dart';
import '../../../core/constants/resource.dart';
import '../../../core/utils/enums.dart';
import '../../../domain/entities/document_entity.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Cần thêm package này
import 'package:percent_indicator/circular_percent_indicator.dart';

class BookCard extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const BookCard({
    Key? key,
    required this.document,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính phần trăm tiến độ đọc
    final progress = document.readingProgress ?? 0.0;
    final progressPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover and progress indicator
            Stack(
              children: [
                // Book cover
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    child: document.coverUrl != null
                        ? CachedNetworkImage(
                      imageUrl: document.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(
                            _getBookIcon(),
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(
                            _getBookIcon(),
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          _getBookIcon(),
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Progress indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: CircularPercentIndicator(
                    radius: 18.0,
                    lineWidth: 3.0,
                    percent: progress,
                    center: Text(
                      "$progressPercent%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: Kolors.kGold,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                ),

                // Play button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Kolors.kGold,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Book title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                document.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Author (if available)
            if (document.author != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  document.author!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            Spacer(),

            // Position/index indicator
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                document.lastReadPage != null
                    ? 'Trang ${document.lastReadPage}'
                    : document.id.substring(0, 3),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBookIcon() {
    return document.type == DocumentType.pdf
        ? Icons.picture_as_pdf
        : Icons.book;
  }
}