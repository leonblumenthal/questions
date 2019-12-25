import 'package:questions/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static List<String> _createTables = [
    'CREATE TABLE Course('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT'
        ');',
    'CREATE TABLE Question('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'text TEXT,'
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
      join(await getDatabasesPath(), 'questions.db'),
      onCreate: (db, version) async {
        for (String s in _createTables) await db.execute(s);
      },
      version: 1,
    );
  }

  static Future<Course> insertCourse(Course course) async {
    int id = await _database.insert(
      'Course',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return course..id = id;
  }

  static Future<Question> insertQuestion(Question question) async {
    int id = await _database.insert(
      'Question',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return question..id = id;
  }

  static Future<List<Course>> getCourses() => _database
      .query('Course')
      .then((v) => v.map((map) => Course.fromMap(map)).toList());

  static Future<List<Question>> getQuestions() => _database
      .query('Question')
      .then((v) => v.map((map) => Question.fromMap(map)).toList());

  static Future<void> deleteCourse(Course course) =>
      _database.delete('Course', where: 'id = ?', whereArgs: [course.id]);

  static Future<void> deleteQuestion(Question question) =>
      _database.delete('Question', where: 'id = ?', whereArgs: [question.id]);
}
