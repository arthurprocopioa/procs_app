import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/camera_utils.dart';
import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';
import 'objective_screen.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen>
    with SingleTickerProviderStateMixin {
  // Camera
  CameraController? _controller;
  CameraDescription? _camera;
  bool _isCameraInitialized = false;

  // ML Kit
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  bool _isProcessingImage = false;

  // Detection Logic
  int _consecutiveValidFrames = 0;
  static const int _requiredValidFrames = 20; // Increase slightly for stability
  bool _isLocked = false; // Prevent double firing

  // UI State
  String _statusText = "Posicione seu corpo na silhueta";
  Color _silhouetteColor = const Color(0xFFD4AF37); // Gold

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('body_scan_active');
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer front camera for "Mirror" feel
      _camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        _camera!,
        ResolutionPreset.low, // Prioritize FPS and processing speed
        enableAudio: false,
        imageFormatGroup: !kIsWeb && Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Start Stream
      if (!kIsWeb) {
        _controller!.startImageStream(_processCameraImage);
      } else {
        // Web Simulation
        _simulateWebDetection();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _simulateWebDetection() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _statusText = "Simulando Detecção...");
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        _captureAndProceed();
      });
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingImage || _isLocked || _camera == null) return;
    _isProcessingImage = true;

    try {
      final inputImage =
          CameraUtils.convertCameraImageToInputImage(image, _camera!);
      if (inputImage == null) {
        _isProcessingImage = false;
        return;
      }

      final poses = await _poseDetector.processImage(inputImage);

      // Use logic based on *rotated* size (metadata) if available,
      // otherwise fallback to raw image width/height.
      // inputImage.metadata.size reflects the rotation processing.
      final imageSize = inputImage.metadata?.size ??
          Size(image.width.toDouble(), image.height.toDouble());

      _validatePose(poses, imageSize);
    } catch (e) {
      // Ignore errors for smoothness
    } finally {
      if (mounted) _isProcessingImage = false;
    }
  }

  void _validatePose(List<Pose> poses, Size imageSize) {
    if (_isLocked) return;

    if (poses.isEmpty) {
      _resetStability("Mantenha o corpo visível");
      return;
    }

    final pose = poses.first;
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    // 1. Basic Visibility Check
    if (leftShoulder == null ||
        rightShoulder == null ||
        leftShoulder.likelihood < 0.6 ||
        rightShoulder.likelihood < 0.6) {
      _resetStability("Iluminação ou posição inadequada");
      return;
    }

    // 2. Center Check
    // Center is imageWidth / 2.
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final centerDiff = (shoulderMidX - (imageSize.width / 2)).abs();
    final centerThreshold = imageSize.width * 0.20; // 20% tolerance (stricter)

    if (centerDiff > centerThreshold) {
      _resetStability("Centralize o corpo");
      return;
    }

    // 3. Distance Check (Shoulder Width)
    final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    if (shoulderWidth < (imageSize.width * 0.25)) {
      _resetStability("Aproxime-se um pouco");
      return;
    }
    if (shoulderWidth > (imageSize.width * 0.85)) {
      _resetStability("Afaste-se um pouco");
      return;
    }

    // === PASSED ALL CHECKS ===
    if (mounted) {
      setState(() {
        _consecutiveValidFrames++;
        // Subtle feedback
        if (_consecutiveValidFrames > 5) {
          _statusText = "Mantenha a posição...";
          _silhouetteColor = Colors.white; // Lock indication
        }
      });
    }

    if (_consecutiveValidFrames >= _requiredValidFrames) {
      _captureAndProceed();
    }
  }

  void _resetStability(String message) {
    if (_consecutiveValidFrames > 0) {
      if (mounted) {
        setState(() {
          _consecutiveValidFrames = 0;
          _statusText = message;
          _silhouetteColor = const Color(0xFFD4AF37);
        });
      }
    }
  }

  void _captureAndProceed() async {
    if (_isLocked) return;
    _isLocked = true; // LOCK

    // 1. Visual & Haptic Success
    HapticService.heavyImpact();
    if (mounted) {
      setState(() {
        _statusText = "Scan Realizado";
        _silhouetteColor = Colors.greenAccent; // Success Color
      });
    }

    // 2. Stop Stream (Save CPU) & Wait workaround for Android crash
    if (!kIsWeb) {
      try {
        await _controller?.stopImageStream();
        if (Platform.isAndroid) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (e) {
        debugPrint("Error stopping stream: $e");
      }
    }

    try {
      // 3. Instant Capture
      final image = await _controller!.takePicture();

      if (!mounted) return;
      context.read<OnboardingProvider>().setBodyScanImage(image.path);

      // 4. Navigate Immediately
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ObjectiveScreen(),
        ));
      }
    } catch (e) {
      debugPrint("Capture failed: $e");
      // Reset if failed
      if (mounted) {
        setState(() {
          _isLocked = false;
          _statusText = "Tente novamente";
          _silhouetteColor = const Color(0xFFD4AF37);
        });
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    _poseDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera
            if (_isCameraInitialized && _controller != null)
              Transform.scale(
                scale: 1.1, // Slight zoom to fill screen properly
                child: Center(
                  child: CameraPreview(_controller!),
                ),
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37))),

            // 2. Overlay
            CustomPaint(
              painter: SilhouettePainter(
                color: Colors.black.withOpacity(0.5),
                borderColor: _silhouetteColor,
              ),
              child: Container(),
            ),

            // 3. UI
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const ProcsBackButton(color: Colors.white),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: PremiumProgressBar(progress: 3 / 17),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Simplified Status
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_statusText),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24)),
                      child: Text(
                        _statusText,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            )
          ],
        ));
  }
}

// Re-using simplified painter
class SilhouettePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  SilhouettePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Dim Background
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final centerX = size.width / 2;
    final centerY = size.height * 0.45;

    // Abstract Silhouette (Head + Torso)
    final silhouettePath = Path();
    silhouettePath.addOval(Rect.fromCenter(
        center: Offset(centerX, centerY - 120),
        width: 140,
        height: 180)); // Head
    silhouettePath.addOval(Rect.fromCenter(
        center: Offset(centerX, centerY + 180),
        width: 340,
        height: 420)); // Torso

    final overlayPath =
        Path.combine(PathOperation.difference, path, silhouettePath);

    canvas.drawPath(
        overlayPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);

    // Border (Glow effect via Shadow if needed, simple stroke for now)
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(silhouettePath, paint);
  }

  @override
  bool shouldRepaint(SilhouettePainter old) => old.borderColor != borderColor;
}
