import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:questions/models.dart';
import 'package:questions/storage.dart';

var mockFile =
    '# Analysis\n\n\n\n## 1. Reelle Zahlen\n\n\n\n- Wann ist eine Menge abzählbar ?\n\n- Ist Q abzählbar ?\n\n- Ist R abzählbar ?\n\n- Was heißt Anordung in Bezug auf (R,+,·) ?\n\n- Was ist eine komplexe Zahl ?\n\n- Welche drei Intervalle gibt es und wie sind sie definiert ?\n\n- Was heißt "nach oben/unten beschränkt" in Bezug auf eine Menge ?\n\n- Was sind Supremum, Infimum, Maximum und Minimum in Bezug auf eine Menge ?\n\n- Was heißt archimedisch ?\n\n- Was heißt Q ist dicht in R ?\n\n- Was ist die Dreiecksungleichung ?\n\n- Was ist die umgekehrte Dreiecks-Ungleichung ?\n\n- Was ist die umgekehrte Cauchy-Schwarz-Ungleichung ?\n\n\n\n## 2. Folgen\n\n\n\n- Was ist eine Folge ?\n\n- Wie sind Konvergenz, Divergenz und uneigentliche Konvergenz definiert ?\n\n- Welche vier Rechenregeln gelten für den Limes von zwei konvergenten Folgen ?\n\n- Wann sind zwei Folgen asymptotisch gleich ?\n\n- Was ist jede konvergente Folge reeller Zahlen ?\n\n- Was gilt für a und b mit a = lim an, b = lim bn und an <= bn ?\n\n- Was besagt die Einschließungsregel ?\n\n- Wann ist eine Folge (streng) monoton wachsend/fallend ?\n\n- Was ist der Limes einer monoton wachsenden/fallenden Folge ?\n\n- Was gilt für eine beschränkte/unbeschränkte monotone Folge ?\n\n- Was ist die Bernoulli-Ungleichung ?\n\n- Wie ist die generelle binomische Formel definiert ?\n\n- Wie ist die geometrische Summe definiert ?\n\n- Welche Folge konvergiert gegen die Eulersche Zahl und welche Eigenschaften hat sie ?\n\n- Welche Folge nennt man "harmonische Zahlen" und welche Eigenschaften hat sie ?\n\n\n\n## 3. Reihen\n\n\n\n- Was ist eine (unendliche) Reihe und Partialsumme ?\n\n- Was sind die harmonische- und die geometrische Reihe definiert ?\n\n- Wie verhält sich der Grenzwert der geometrischen Reihe ?\n\n- Was passiert, wenn man endlich viele Terme einer Reihe weglässt ?\n\n- Was ist das notwendige Kriterium für Konvergenz einer Reihe ?\n\n- Was sind das Majoraten- und das Minoratenkriterium ?\n\n- Was sind die Reihen zweier Folgen > 0, die asymptotisch gleich sind ?\n\n- Was ist das Quotientenkriterium ?\n\n- Was ist die Exponentialreihe und wie ist ihr Konvergenzverhalten ?\n\n- Wann konvergiert eine alternierende Reihe ?\n\n- Was ist die Leibnizreihe und wie ist ihr Konvergenzverhalten ?\n\n- Was gilt für die Summe von zwei konvergenten Reihen ?\n\n- Was ist das Cauchy-Produkt ?\n\n- Was ist die Exponentialfunktion und welche sechs Eigenschaften hat sie ?\n\n\n\n## 4. Stetigkeit\n\n\n\n- Wann konvergiert eine Folge von Vektoren ?\n\n- Wann ist eine Funktion (in einem Punkt) stetig ?\n\n- Welche Zusammensetzungen von stetigen Funktionen sind stetig ?\n\n- Was besagt der Zwischenwertsatz ?\n\n- Was ist ein Häufungspunkt ?\n\n- Was besagt der Bolzano-Weierstrass-Satz ?\n\n- Wann ist eine Menge abgeschlossen, kompakt oder beschränkt ?\n\n- Was besitzt eine kompakte Menge ?\n\n- Was ist das Bild von einer kompakten Menge unter einer stetigen Funktion ?\n\n- Was besagt der Satz von Maximum und Minimum ?\n\n\n\n## 5. Wichtige Funktionen\n\n\n\n- Was bedeutet Bijektivität ?\n\n- Was gilt für die Umkehrfunktionen von stetig und streng monoton wachsenden Funktionen ?\n\n- Welche drei Rechenregeln gelten für den Logarithmus ?\n\n- Was gilt für das Wachstum der Exponentialfunktion ?\n\n- Was gilt für das Wachstum der Logarithmusfunktion ?\n\n- Wie kann die allgemeine Potenzfunktion x^a noch ausgedrückt werden ?\n\n- Was besagt die Eulersche Formel ?\n\n- Was folgt aus dem Satz von Pythagoras und der Eulerschen Formel ?\n\n- Wie lauten die Reihendarstellungen von Sinus und Kosinus ?\n\n- Wie ist der Grenzwert einer Funktion gegen eine bestimmte Stelle definiert ?\n\n- Was sind die Umkehrfunktionen der drei trigonometrischen Funktionen und welchen Definitionsbereich haben sie jeweils ?\n\n\n\n## 6. Differenzierbarkeit\n\n\n\n- Was bedeutet f(x) = O(g(x)) für x -> x0/∞ ?\n\n- Was bedeutet f(x) = o(g(x)) für x -> x0/∞ ?\n\n- Wann ist eine Funktion (in einem Punkt) differenzierbar ?\n\n- Was folgt aus Differenzierbarkeit ?\n\n- Was ist die Ableitug von Sinus und Kosinus ?\n\n- Welche vier Regeln gibt es beim ableiten ?\n\n- Was sind die Ableitunge von arcsin, arccos und arctan ?\n\n\n\n## 7. Anwendungen der Ableitung\n\n\n\n- Was für Extrema gibt es und was sind ihre Eigenschaften ?\n\n- Welche notwendige gilt für Extrema ?\n\n- Welche beiden hinreichenden Bedingungen gelten für Extrema ?\n\n- Was ist der Mittelwertsatz der Differentialrechnung ?\n\n- Was ist der Satz von Rolle ?\n\n- Was ist der verallgemeinerte Mittelwertsatz ?\n\n- Wann ist eine Funktion (streng) monoton wachsend/fallend ?\n\n- Welche vier Monotoniekriterien gelten für eine differenzierbare Funktion ?\n\n- Was besagt die Regel von l\'Hospital und welche Voraussetzugen hat sie ?\n\n- Wie ist (strikt) konvex bzw. konkav definiert ?\n\n- Welche Teile hat die Kurvendiskussion ?\n\n\n\n## 8. Integration\n\n\n\n- Was besschreibt ein bestimmtes Integral ?\n\n- Welche fünf Rechenregeln gelten für Integrale ?\n\n- Was ist jede stetige Funktion ?\n\n- Was ist der Mittelwertsatz der Integralrechnung ?\n\n- Was ist eine Stammfunktion ?\n\n- Wie berechnet man ein bestimmtes Integral ?\n\n- Welche drei wichtige Methoden gibt es bei der Integration ?\n\n\n\n## 9. Mehr über Integrale\n\n- Was ist ein uneigentliches Integral ?\n\n- Was ist der rechtsseitige- und linksseitige Grenzwert ?\n\n- Was ist die partielle Ableitung ? \n\n- Welche drei Eigenschaften hat eine Funktion mit zwei Parametern ?\n\n \n';

class ImportWidget extends StatefulWidget {
  @override
  _ImportWidgetState createState() => _ImportWidgetState();
}

class _ImportWidgetState extends State<ImportWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        child: Text('Import'),
        onPressed: () async {
          await import();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future import() async {
    File file = await FilePicker.getFile();
    if (file == null) return;

    var courseImports = parse(file.readAsStringSync());

    courseImports.forEach((courseImport) async {
      if (courseImport.import) {
        await Storage.insertCourse(courseImport.course);
        courseImport.sectionImports.forEach((sectionImport) async {
          if (sectionImport.import) {
            await Storage.insertSection(
              sectionImport.section..courseId = courseImport.course.id,
            );
            sectionImport.questionImports.forEach((questionImport) {
              if (questionImport.import) {
                Storage.insertQuestion(
                  questionImport.question..sectionId = sectionImport.section.id,
                );
              }
            });
          }
        });
      }
    });
  }

  List<CourseImport> parse(String raw) {
    Function isNotCourseTitle = (String line) => !line.startsWith('# ');
    Function isNotSectionTitle = (String line) => !line.startsWith('## ');
    Function isQuestionText = (String line) => line.startsWith('- ');

    List<CourseImport> courseImports = [];

    List<String> lines = [
      for (String line in raw.split('\n')) if (line.isNotEmpty) line.trim()
    ];

    // Skip to first course.
    lines = lines.skipWhile((line) => !line.startsWith('# ')).toList();

    while (lines.isNotEmpty) {
      CourseImport courseImport = CourseImport(
        Course(title: lines.first.substring(2)),
      );
      courseImports.add(courseImport);
      // Skip course title.
      lines = lines.skip(1).toList();
      // Take all lines before the next course and skip to first section
      List<String> courseLines = lines
          .takeWhile(isNotCourseTitle)
          .skipWhile(isNotSectionTitle)
          .toList();

      while (courseLines.isNotEmpty) {
        SectionImport sectionImport = SectionImport(
          Section(title: courseLines.first.substring(3)),
          courseImport,
        );
        courseImport.sectionImports.add(sectionImport);
        // Skip section title.
        courseLines = courseLines.skip(1).toList();
        // Take all lines before the next section and remove invalid lines.
        List<String> sectionLines = courseLines
            .takeWhile(isNotSectionTitle)
            .where(isQuestionText)
            .toList();
        for (String line in sectionLines) {
          sectionImport.questionImports.add(QuestionImport(
            Question(text: line.substring(2)),
            sectionImport,
          ));
        }
        // Remove section lines from course lines.
        courseLines = courseLines.skipWhile(isNotSectionTitle).toList();
      }
      // Remove course lines from all lines.
      lines = lines.skipWhile(isNotCourseTitle).toList();
    }
    return courseImports;
  }
}
