import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // متغير لمنع تكرار فتح النتيجة عند قراءة الكود أكثر من مرة في نفس اللحظة
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الـ QR Code'), centerTitle: true),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() {
                isScanned = true;
              });

              final String link = barcode.rawValue!;

              // إغلاق الكاميرا وإرجاع اللينك للشاشة السابقة أو إظهاره
              _showResultDialog(link);
              break;
            }
          }
        },
      ),
    );
  }

  // نافذة إظهار الرابط بعد المسح
  void _showResultDialog(String link) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم قراءة الرابط بنجاح!'),
        content: SelectableText(link), // يتيح للمستخدم نسخ الرابط
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق النافذة
              setState(() {
                isScanned = false; // إعادة تفعيل المسح
              });
            },
            child: const Text('مسح كود آخر'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق النافذة
              Navigator.pop(context, link); // الرجوع للشاشة الرئيسية مع اللينك
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }
}

// 1. التطبيق الرئيسي يغلف التطبيق بـ MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HOme(), // استدعاء الشاشة المستقلة
    );
  }
}

class HOme extends StatefulWidget {
  const HOme({super.key});

  @override
  State<HOme> createState() => _HOmeState();
}

class _HOmeState extends State<HOme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/download.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
           
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 80, 11, 6),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                width: 150,
                height: 30,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QRScannerScreen()),
                    );
                  },
                  child: Text("Scan", style: TextStyle(fontSize: 20)),
                ),
              ),
            
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 80, 11, 6),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 150,
              height: 30,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => QrHomeScreen()),
                  );
                },
                child: Text("Create QrCode", style: TextStyle(fontSize: 20)),
              ),
            ),
         
        
          ]
        )
      ),
    );
  }
}

// 2. فصل الشاشة في StatefulWidget مستقل ليكون للـ context وصول لـ MaterialLocalizations
class QrHomeScreen extends StatefulWidget {
  const QrHomeScreen({super.key});

  @override
  State<QrHomeScreen> createState() => _QrHomeScreenState();
}

class _QrHomeScreenState extends State<QrHomeScreen> {
  TextEditingController textdata = TextEditingController();
  String data = "";

  @override
  void dispose() {
    textdata.dispose();
    super.dispose();
  }

  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context, // الآن سيجد context يتبع لـ MaterialApp بنجاح
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('تنزيل الصورة على التليفون'),
                onTap: () async {
                  Navigator.pop(context);

                  final qrValidationResult = QrValidator.validate(
                    data: data,
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.L,
                  );

                  if (qrValidationResult.status == QrValidationStatus.valid) {
                    final qrCode = qrValidationResult.qrCode;
                    final painter = QrPainter.withQr(
                      qr: qrCode!,
                      emptyColor: Colors.white,
                      gapless: true,
                    );

                    final picData = await painter.toImageData(300);

                    if (picData != null) {
                      final Uint8List imageBytes = picData.buffer.asUint8List();

                      await Gal.putImageBytes(imageBytes);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تنزيل الصورة بنجاح!'),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/download.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Text(
              "إنشاء Qr_Code",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.only(
                right: 40,
                left: 40,
                top: 40,
                bottom: 20,
              ),
              child: TextField(
                style: const TextStyle(
                  color: Color.fromARGB(255, 123, 255, 128),
                ),
                controller: textdata,
                decoration: InputDecoration(
                  hintText: "أدخل اللينك",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 93, 247, 101),
                  ),
                  fillColor: const Color.fromARGB(255, 88, 19, 19),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (textdata.text.isNotEmpty) {
                      setState(() {
                        data = textdata.text;
                        textdata.clear();
                      });
                    }
                  },
                  child: const Text(
                    "Create",
                    style: TextStyle(color: Color.fromARGB(255, 126, 255, 131)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (data.isNotEmpty)
              Center(
                child: GestureDetector(
                  onLongPress: _showOptionsDialog,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: QrImageView(
                      data: data,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
