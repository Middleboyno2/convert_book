import 'dart:io';

import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_event.dart';
import 'package:doantotnghiep/presentation/widgets/custom_toast/CustomToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/resource.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool loading = false;

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: true, // false nếu không muốn yêu cầu quyền truy cập thư viện ảnh
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  void _upload(File file){
    context.read<AuthBloc>().add(UploadProfileImageRequested(file: file));
  }

  Future<void> _captureImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            context.pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: _pickImageFromGallery,
            icon:Icon(Icons.photo_library),
          ),
          IconButton(
            onPressed: _captureImageFromCamera,
            icon:Icon(Icons.camera),
          ),
          _imageFile != null?
          IconButton(
            onPressed: (){
              _upload(_imageFile!);
            },
            icon:Icon(Icons.check),
          )
              :
          SizedBox(),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state){
          if(state is UploadImageCompleted){
            Toast.showCustomToast(context,AppLocalizations.of(context).translate('message.message_update_image'));

          }
          if(state is AuthAuthenticated){
            print("Authenticated with user: ${state.user.email}");
            setState(() {
              loading = false;
            });
            context.pop();
          }
          if(state is UploadLoading){
            setState(() {
              loading = true;
            });
          }
          if(state is UploadProfileImageError){
            Toast.showCustomToast(context, 'Lỗi cập nhật ảnh: ${state.failure.message}');
            setState(() {
              loading = false;
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Center(
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : Image.asset(R.ASSETS_IMAGE_ERROR_IMAGE),
              ),
              if(loading || state is UploadLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
