import 'package:questions/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static const List<String> _createTables = [
    'CREATE TABLE Course('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT'
        ');',
    'CREATE TABLE Section('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'courseId INTEGER REFERENCES Course(id) ON DELETE SET NULL'
        ');',
    'CREATE TABLE Question('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'text TEXT,'
        'streak INTEGER,'
        'lastAnswered INTEGER,'
        'sectionId INTEGER REFERENCES Section(id) ON DELETE SET NULL'
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

  static Future<Section> insertSection(Section section) async {
    int id = await _database.insert(
      'Section',
      section.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return section..id = id;
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

  static Future<List<Section>> getSections(Course course) =>
      _database.query('Section', where: 'courseId = ?', whereArgs: [
        course.id ?? -1
      ]).then((v) => v.map((map) => Section.fromMap(map)).toList());

  static Future<List<Question>> getQuestions(Section section) =>
      _database.query('Question', where: 'sectionId = ?', whereArgs: [
        section.id ?? -1
      ]).then((v) => v.map((map) => Question.fromMap(map)).toList());

  static Future<Course> getCourse(int id) =>
      _database.query('Course', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Course.fromMap(v.first),
      );

  static Future<Section> getSection(int id) =>
      _database.query('Section', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Section.fromMap(v.first),
      );

  static Future<Question> getQuestion(int id) =>
      _database.query('Question', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Question.fromMap(v.first),
      );

  static Future<void> deleteCourse(Course course) =>
      _database.delete('Course', where: 'id = ?', whereArgs: [course.id]);

  static Future<void> deleteSection(Section section) =>
      _database.delete('Section', where: 'id = ?', whereArgs: [section.id]);

  static Future<void> deleteQuestion(Question question) =>
      _database.delete('Question', where: 'id = ?', whereArgs: [question.id]);
}
