import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/utils.dart';

/// A service to handle media selection (images, videos, files).
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final ImagePicker _imagePicker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Camera permission denied');
    }
  }

  Future<void> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }
  }

  Future<void> _ensureGalleryPermission({required bool forVideo}) async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        throw Exception(
            forVideo ? 'Videos permission denied' : 'Photos permission denied');
      }
      return;
    }

    if (!Platform.isAndroid) return;

    final androidInfo = await _deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    final permission = sdkInt >= 33
        ? (forVideo ? Permission.videos : Permission.photos)
        : Permission.storage;
    final status = await permission.request();

    if (!status.isGranted && !status.isLimited) {
      throw Exception(
          forVideo ? 'Videos permission denied' : 'Photos permission denied');
    }
  }

  /// Pick an image from gallery or camera.
  FutureEither<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return runTask(() async {
      if (source == ImageSource.camera) {
        await _ensureCameraPermission();
      } else {
        await _ensureGalleryPermission(forVideo: false);
      }

      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return file != null ? File(file.path) : null;
    });
  }

  /// Pick multiple images from gallery.
  FutureEither<List<File>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return runTask(() async {
      await _ensureGalleryPermission(forVideo: false);

      final List<XFile> files = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return files.map((file) => File(file.path)).toList();
    });
  }

  /// Pick a video from gallery or camera.
  FutureEither<File?> pickVideo({
    required ImageSource source,
    Duration? maxDuration,
  }) async {
    return runTask(() async {
      if (source == ImageSource.camera) {
        await _ensureCameraPermission();
        await _ensureMicrophonePermission();
      } else {
        await _ensureGalleryPermission(forVideo: true);
      }

      final XFile? file = await _imagePicker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      return file != null ? File(file.path) : null;
    });
  }
}
