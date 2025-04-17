import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ChartExporter {
  final GlobalKey chartkey;
  ChartExporter(this.chartkey);

  Future<ui.Image> renderChartAsImage() async {
    RenderRepaintBoundary boundary =
        chartkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: 3.0);
  }

  // Exportiert das Diagramm in eine PDF-Datei
  Future<String?> exportToPDF(String fileName) async {
    try {
      // Diagramm als Bild rendern
      final ui.Image chartImage = await renderChartAsImage();

      // Bild in Byte-Daten umwandeln
      final ByteData? byteData = await chartImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      // PDF-Dokument erstellen
      final pdf = pw.Document();

      // Bild in die PDF-Seite einfügen
      final pdfImage = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          },
        ),
      );

      // PDF-Datei speichern
      final outputDir = await getApplicationDocumentsDirectory();
      final outputFile = File("${outputDir.path}/$fileName.pdf");
      await outputFile.writeAsBytes(await pdf.save());

      print("PDF gespeichert: ${outputFile.path}");
      return outputFile.path;
    } catch (e) {
      print("Fehler beim Exportieren des Diagramms: $e");
      return null;
    }
  }
}
