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
  Future<void> exportToPDF(String fileName) async {
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
    } catch (e) {
      print("Fehler beim Exportieren des Diagramms: $e");
    }
  }

  ///TODO: Methoden aufruf der in ChartPage oder so gezogen werden muss
  ///Sollte schon gemacht sein, evtl checken das alles funktioniert, solange noch
  ///hier stehen lassen
  /*final GlobalKey _chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chartConfig.title),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              final exporter = ChartExporter(_chartKey);
              exporter.exportToPDF("Diagramm_Export");
            },
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _chartKey,
        child:
            Sensordata(
              selectedLines: selectedValues,
              chartConfig: widget.chartConfig,
            ).getLineChart(),
      ),
    );
  }*/
}
