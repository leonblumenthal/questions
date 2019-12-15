import 'package:questions/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static List<String> _createTables = [
    'CREATE TABLE Course('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEST'
        ');',
    'CREATE TABLE Question('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'text TEST,'
        'created INTEGER,'
        'totalTries INTEGER,'
        'correctTries INTEGER,'
        'lastAnswered INTEGER,'
        'courseId INTEGER REFERENCES Course(id) ON DELETE SET NULL'
        ');'
  ];

  static Database _database;

  static Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'mood.db'),
      onCreate: (db, version) async {
        for (String s in _createTables) await db.execute(s);
      },
      version: 1,
    );
  }

  static Future<void> insertCourse(Course course) async =>
      await _database.insert(
        'Course',
        course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  static Future<void> insertQuestion(Question question) async =>
      await _database.insert(
        'Question',
        question.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  static Future<List<Course>> getCourses({int id}) => _database
      .query('Course')
      .then((v) => v.map((map) => Course.fromMap(map)).toList());

  static Future<List<Question>> getQuestions({int id, Course course}) =>
      _database
          .query('Question')
          .then((v) => v.map((map) => Question.fromMap(map)).toList());
}
