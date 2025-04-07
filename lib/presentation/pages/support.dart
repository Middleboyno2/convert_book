import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null, // Cho phép xuống dòng không giới hạn
            minLines: 1,    // Bắt đầu với 1 dòng, tự động mở rộng
            decoration: InputDecoration(
              labelText: 'Nhập nội dung...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 10,
          ),

          CustomButton(onPressed: (){}, text: 'send')

        ],
      ),
    );
  }
}
