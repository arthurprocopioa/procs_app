import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CameraUtils {
  static InputImage? convertCameraImageToInputImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) {
    final allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final InputImageRotation? rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final InputImageFormat? format =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw);
    if (format == null) return null;

    // InputImageData is deprecated in newer versions, use InputImageMetadata
    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }
}
