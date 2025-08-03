import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../helper/global_variables.dart';

class FileUploadService {
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final String _baseUrl = GlobalVariables().localhost;

  /// Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick an image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Upload file to server
  Future<FileUploadResult> uploadFile(XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/api/chat/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['url'] != null) {
        return FileUploadResult(
          success: true,
          fileUrl: response.data['url'],
          fileType: response.data['fileType'] ?? 'image',
          fileName: file.name,
        );
      } else {
        throw Exception('Upload failed: Invalid response');
      }
    } catch (e) {
      return FileUploadResult(
        success: false,
        error: 'Upload failed: $e',
      );
    }
  }

  /// Pick and upload image from gallery
  Future<FileUploadResult> pickAndUploadFromGallery() async {
    try {
      final pickedFile = await pickImageFromGallery();
      if (pickedFile == null) {
        return FileUploadResult(
          success: false,
          error: 'No image selected',
        );
      }
      return await uploadFile(pickedFile);
    } catch (e) {
      return FileUploadResult(
        success: false,
        error: 'Failed to pick and upload image: $e',
      );
    }
  }

  /// Pick and upload image from camera
  Future<FileUploadResult> pickAndUploadFromCamera() async {
    try {
      final pickedFile = await pickImageFromCamera();
      if (pickedFile == null) {
        return FileUploadResult(
          success: false,
          error: 'No photo taken',
        );
      }
      return await uploadFile(pickedFile);
    } catch (e) {
      return FileUploadResult(
        success: false,
        error: 'Failed to take and upload photo: $e',
      );
    }
  }

  /// Validate file size (in bytes)
  bool isFileSizeValid(File file, {int maxSizeInMB = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Validate file type
  bool isImageFile(String fileName) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final lowerCaseFileName = fileName.toLowerCase();
    return validExtensions.any((ext) => lowerCaseFileName.endsWith(ext));
  }
}

/// Result class for file upload operations
class FileUploadResult {
  final bool success;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;
  final String? error;

  FileUploadResult({
    required this.success,
    this.fileUrl,
    this.fileType,
    this.fileName,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'FileUploadResult(success: $success, fileUrl: $fileUrl, fileType: $fileType)';
    } else {
      return 'FileUploadResult(success: $success, error: $error)';
    }
  }
}