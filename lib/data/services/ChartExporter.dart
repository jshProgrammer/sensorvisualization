import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ChartExporter {
  final GlobalKey chartkey;
  ChartExporter(this.chartkey, this.legendData);
  final List<Map<String, dynamic>> legendData;

  late final pw.Font regularFont;

  Future<void> loadFonts() async {
    regularFont = pw.Font.ttf(await rootBundle.load("fonts/Roboto.ttf"));
  }

  Future<ui.Image> renderChartAsImage() async {
    RenderRepaintBoundary boundary =
        chartkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: 3.0);
  }

  List<Map<String, dynamic>> _extractChartData() {
    try {
      print("=== EXTRACT CHART DATA DEBUG ===");

      final context = chartkey.currentContext;
      if (context == null) {
        print("ERROR: Kein Context gefunden");
        return [];
      }

      final widget = chartkey.currentWidget;
      if (widget == null) {
        print("ERROR: Kein Widget gefunden");
        return [];
      }

      print("Root Widget Typ: ${widget.runtimeType}");

      final lineChart = _findLineChart(widget);

      if (lineChart == null) {
        print("ERROR: Kein LineChart im Widget-Baum gefunden");
        return [];
      }

      print("LineChart gefunden!");
      final data = lineChart.data;
      print("Anzahl Linien: ${data.lineBarsData.length}");

      if (data.lineBarsData.isEmpty) {
        print("ERROR: Keine Linien-Daten vorhanden");
        return [];
      }

      List<Map<String, dynamic>> chartInfo = [];
      int sensorIndex = 0;

      for (var line in data.lineBarsData) {
        print("Verarbeite Linie $sensorIndex:");
        print("  - Spots: ${line.spots.length}");
        print("  - Farbe: ${line.color}");

        if (line.spots.isNotEmpty) {
          final sensorData = {
            'name': 'Sensor ${sensorIndex + 1}',
            'color': PdfColor.fromInt(line.color?.value ?? 0xFF000000),

            'data':
                line.spots.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
          };

          chartInfo.add(sensorData);
          print("  - Hinzugefügt: ${sensorData['name']}");
        } else {
          print("  - Übersprungen (keine Spots)");
        }

        sensorIndex++;
      }

      print("Finale Chart-Info: ${chartInfo.length} Sensoren");
      return chartInfo;
    } catch (e, stack) {
      print("FEHLER in _extractChartData: $e");
      print("Stack: $stack");
      return [];
    }
  }

  LineChart? _findLineChart(Widget widget) {
    print("Suche in Widget: ${widget.runtimeType}");

    if (widget is LineChart) {
      print("LineChart gefunden!");
      return widget;
    }

    if (widget is RepaintBoundary) {
      print("  - Suche in RepaintBoundary child");
      if (widget.child != null) {
        return _findLineChart(widget.child!);
      }
      return null;
    }

    if (widget is Padding) {
      print("  - Suche in Padding child");
      if (widget.child != null) {
        return _findLineChart(widget.child!);
      }
      return null;
    }

    if (widget is Container) {
      print("  - Suche in Container child");
      if (widget.child != null) {
        return _findLineChart(widget.child!);
      }
    }

    if (widget is Center) {
      print("  - Suche in Center child");
      if (widget.child != null) {
        return _findLineChart(widget.child!);
      }
      return null;
    }

    if (widget is Expanded) {
      print("  - Suche in Expanded child");
      return _findLineChart(widget.child);
    }

    if (widget is Column) {
      print("  - Suche in Column children");
      for (var child in widget.children) {
        final result = _findLineChart(child);
        if (result != null) return result;
      }
    }

    if (widget is Row) {
      print("  - Suche in Row children");
      for (var child in widget.children) {
        final result = _findLineChart(child);
        if (result != null) return result;
      }
    }

    if (widget is Stack) {
      print("  - Suche in Stack children");
      for (var child in widget.children) {
        final result = _findLineChart(child);
        if (result != null) return result;
      }
    }

    print("  - Kein LineChart in ${widget.runtimeType} gefunden");
    return null;
  }

  Future<String?> exportToPDF(String fileName) async {
    await loadFonts();
    try {
      if (chartkey.currentContext == null) {
        print("Error: Kein gültiger Context für chartkey");
        return null;
      }

      final ui.Image chartImage = await renderChartAsImage();

      final ByteData? byteData = await chartImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        print("Error: Konnte keine ByteData aus dem Chart-Image extrahieren");
        return null;
      }

      List<Map<String, dynamic>> chartData;
      try {
        chartData = _extractChartData();
      } catch (e) {
        print("Error beim Extrahieren der Chart-Daten: $e");
        return null;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);

      try {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) {
              return pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Center(
                      child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Legende',
                            style: pw.TextStyle(
                              font: regularFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          ...legendData.map((entry) {
                            return pw.Row(
                              children: [
                                pw.Container(
                                  width: 20,
                                  height: 10,
                                  color: PdfColor.fromInt(
                                    (entry['color'] as Color).value,
                                  ),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(
                                  "${sanitizeString(entry['device'])} – ${entry['sensorName']} - ${entry['attribute']}",
                                  style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        final outputDir = await getApplicationDocumentsDirectory();
        final outputFile = File("${outputDir.path}/$fileName.pdf");
        await outputFile.writeAsBytes(await pdf.save());

        print("PDF erfolgreich gespeichert unter: ${outputFile.path}");
        return outputFile.path;
      } catch (e) {
        print("Fehler beim Erstellen oder Speichern des PDFs: $e");
        return null;
      }
    } catch (e) {
      print("Allgemeiner Fehler beim PDF-Export: $e");
      return null;
    }
  }

  pw.Widget _buildLegendEntry(
    String label,
    PdfColor color, {
    bool isDashed = false,
    List<int>? dashPattern,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 30,
            height: 3,
            margin: const pw.EdgeInsets.only(right: 8),
            decoration: pw.BoxDecoration(color: color),
          ),

          pw.Expanded(child: pw.Text(label, style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  String sanitizeString(String input) {
    return input.replaceAll(RegExp(r'[^\w\s-]'), '');
  }
}
