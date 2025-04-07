# Visualisierung von Smartphone-Sensordaten
## für Arbeiten im Zivil- und Katastrophenschutz - in Zusammenarbeit mit dem THW

### Das Smartphone als Multisensorplatform
Was noch vor einigen Jahre ausschließlich Fachanwendern vorbehalten
war, trägt heutzutage jeder in der Hosentasche bei sich.
Die in aktuellen Smartphones verbaute Sensortechnik liefert eine weitaus
größere Vielfalt an Daten, als den meisten Nutzern überhaupt bewusst ist.
Allseits bekannt sind Sensoren zur Positionsbestimmung aus
Satellitendaten oder die Nutzung des Neigungssensors als Wasserwaage,
da deren Daten unmittelbar mit einer gewünschten Funktion in
Verbindung gebracht werden kann.
Sensoren die eher im Hintergrund agieren, wie beispielsweise der
Beschleunigungssensor, das Gyroskop oder das Magnetometer, sind
hingegen oft unbekannt oder werden nur passiv wahrgenommen.
Das Ziel des Projektes „Libelle“ ist es, die im dabei registrierten
Umgebungsdaten einem Anwender so zur Verfügung zu stellen, dass
Smartphones als multifunktionaler Sensor im Kontext einer
Bauwerksüberwachung eingesetzt werden können.

## Projektüberblick
Dieses Projekt wird im Rahmen des Programmierprojekts im Studiengang Informatik an der THWS durchgeführt. Zwei Systeme werden entwickelt: Ein Smartphone übermittelt die aktuellen Messdaten an einen Empfänger, der diese Daten anschließend visuell darstellt.

Zentrale Punkte:
- Darstellung von Graphen aus den Daten der Smartphone-
Sensorik (Neigungsmesser, Beschleunigungsmesser, Kompass, …)
- Visualisierung als Zeit-Messwert-Diagramme
- Verknüpfung verschiedener Datenquellen (im gleichen Diagramm)
- Anpassbare Zeitbereiche (fortlaufend und verschiebbar)
- „Event“-Markierung mit Notizfunktion
- Auf „Null“ setzen der Startwerte
- Hinzufügen weiterer Diagramme
- Export (*.csv)


## Tech Stack

- **Frontend**: Flutter (Mobile & Web)


#### Flutter-App starten

```bash
cd flutter_app
flutter pub get
flutter run
```

## Mögliche zukünftige Features

- Frei wählbarer Kombination der Messwerte (mehrere Skalen am Diagrammrand)
- Umrechnung der Messwerte (z.B. Winkeländerung in °Grad oder mm/m)
- Plotten der Graphen (zur Dokumentation und Weitergabe)
- Definition von Warnschwellen (Alarmierung bei Überschreitung)
- „Null“-Messung (z.B. 10sek.) zur Ermittlung der Startwerte
- „Systemzeit“ oder „Zeit ab Start“ für die Zeitachse wählbar


## Projektstruktur

```plaintext
sensorvisualization/
├── lib/
│   ├── data/                 
│   |   ├── models/         
│   |   ├── services/              
│   ├── presentation/    
│   |   ├── screens/
│   |   ├── widgets/          
│   └── main.dart       # entry point
├── pubspec.yaml
└── README.md
```

## Contributor

- [Jasmin Wander] https://github.com/xjasx4
- [Sebastian Nagles] https://github.com/SebasN12
- [Tom Knoblach] https://github.com/Gottschalk125
- [Joshua Pfennig] https://github.com/jshProgrammer