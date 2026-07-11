import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// conditional import
import 'pdf_stub_download.dart'
if (dart.library.html) 'pdf_web_download.dart';

class PdfExportService {
  static Future<void> exportTodayMealPdf({
    required String date,
    required List<Map<String, String>> meals,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Today's Meal Plan",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text("Date: $date"),
            pw.Divider(),
            ...meals.map(
                  (meal) => pw.Text(
                "${meal['time']} - ${meal['name']} (${meal['calories']} kcal)",
              ),
            ),
          ],
        ),
      ),
    );

    final Uint8List bytes = await pdf.save();

    if (kIsWeb) {
      downloadPdfOnWeb(bytes); // ✅ WORKS
    }
  }
}
