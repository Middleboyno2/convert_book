import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/resource.dart';

class AvatarProfile extends StatelessWidget {
  final String id;
  final String avatarUrl;
  const AvatarProfile({super.key, required this.avatarUrl, required this.id});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Kolors.kGold)
              ),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(R.ASSETS_IMAGE_PROFILE_NOT_FOUND, fit: BoxFit.cover);
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
            Positioned(
              right: 2,
              bottom: 2,
              width: 35,
              height: 35,
              child: GestureDetector(
                onTap: (){},
                child:CircleAvatar(
                  backgroundColor: Kolors.kGold,
                  child: Icon(
                    Icons.edit,
                  ),
                ),
              )
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        // id user
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelMedium,
            children: [
              TextSpan(
                text: "ID: "
              ),
              TextSpan(
                text: id,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Clipboard.setData(ClipboardData(text: id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã copy: $id')),
                    );
                  },
              ),
            ]
          )
        ),
      ],
    );
  }
}
