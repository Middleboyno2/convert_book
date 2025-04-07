import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../core/constants/resource.dart';

class CardBook extends StatelessWidget {
  final String imageUrl;
  final String progress;

  const CardBook({super.key, required this.imageUrl, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth / 2 - 20,
      height: 250,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(R.ASSETS_IMAGE_ERROR_IMAGE, fit: BoxFit.cover);
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return Center(child: CircularProgressIndicator()); // Hiển thị loading
                  }
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(seconds: 1),
                    child: child, // Ảnh sẽ hiện dần lên
                  );
                },
              ),
            ),

            // Thanh tiến trình
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  progress,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Nút phát
            Positioned(
              bottom: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.8),
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
