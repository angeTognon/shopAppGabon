// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class QRScannerScreen extends StatefulWidget {
//   final Function(String) onScanSuccess;

//   const QRScannerScreen({super.key, required this.onScanSuccess});

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   // QRViewController? controller;
//   bool _flashOn = false;
//   bool _hasScanned = false;

//   @override
//   void initState() {
//     super.initState();
//     _requestCameraPermission();
//   }

//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     if (status != PermissionStatus.granted) {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Camera view
//             QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//               overlay: QrScannerOverlayShape(
//                 borderColor: Colors.white,
//                 borderRadius: 10,
//                 borderLength: 30,
//                 borderWidth: 10,
//                 cutOutSize: 250,
//               ),
//             ),
            
//             // Header
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                     const Text(
//                       'Scanner QR Code',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 40),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Instructions
//             const Positioned(
//               bottom: 200,
//               left: 0,
//               right: 0,
//               child: Text(
//                 'Placez le code QR dans le cadre pour le scanner',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
            
//             // Controls
//             Positioned(
//               bottom: 80,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildControlButton(
//                     icon: _flashOn ? Icons.flash_on : Icons.flash_off,
//                     label: 'Flash',
//                     onTap: _toggleFlash,
//                     isActive: _flashOn,
//                   ),
//                   if (_hasScanned)
//                     _buildControlButton(
//                       icon: Icons.refresh,
//                       label: 'Rescanner',
//                       onTap: _resetScanner,
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool isActive = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             size: 24,
//             color: isActive ? const Color(0xFFF59E0B) : Colors.white,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       if (!_hasScanned && scanData.code != null) {
//         setState(() {
//           _hasScanned = true;
//         });
        
//         // Vibrate and close scanner
//         controller.pauseCamera();
//         Navigator.pop(context);
//         widget.onScanSuccess(scanData.code!);
//       }
//     });
//   }

//   void _toggleFlash() {
//     controller?.toggleFlash();
//     setState(() {
//       _flashOn = !_flashOn;
//     });
//   }

//   void _resetScanner() {
//     setState(() {
//       _hasScanned = false;
//     });
//     controller?.resumeCamera();
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }