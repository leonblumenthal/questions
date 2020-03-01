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
        'courseId INTEGER REFERENCES Course(id) ON DELETE CASCADE'
        ');',
    'CREATE TABLE Question('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'text TEXT,'
        'streak INTEGER,'
        'lastAnswered INTEGER,'
        'sectionId INTEGER REFERENCES Section(id) ON DELETE CASCADE,'
        'markerId INTEGER REFERENCES Marker(id) ON DELETE CASCADE'
        ');',
    'CREATE TABLE Reference('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'path TEXT,'
        'added INTEGER,'
        'courseId INTEGER REFERENCES Course(id) ON DELETE CASCADE'
        ');',
    'CREATE TABLE Marker('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'pageIndex INTEGER,'
        'px INTEGER,'
        'py INTEGER,'
        'referenceId INTEGER REFERENCES Reference(id) ON DELETE CASCADE'
        ');',
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

  static Future<Reference> insertReference(Reference reference) async {
    int id = await _database.insert(
      'Reference',
      reference.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return reference..id = id;
  }

  static Future<Marker> insertMarker(Marker marker) async {
    int id = await _database.insert(
      'Marker',
      marker.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return marker..id = id;
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

  static Future<List<Reference>> getReferences(Course course) =>
      _database.query('Reference', where: 'courseId = ?', whereArgs: [
        course.id ?? -1
      ]).then((v) => v.map((map) => Reference.fromMap(map)).toList());

  static Future<List<Marker>> getMarkers(Reference reference) =>
      _database.query('Marker', where: 'referenceId = ?', whereArgs: [
        reference.id ?? -1
      ]).then((v) => v.map((map) => Marker.fromMap(map)).toList());

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

  static Future<Reference> getReference(int id) =>
      _database.query('Reference', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Reference.fromMap(v.first),
      );

  static Future<Marker> getMarker(int id) =>
      _database.query('Marker', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Marker.fromMap(v.first),
      );

  static Future<void> deleteCourse(Course course) =>
      _database.delete('Course', where: 'id = ?', whereArgs: [course.id]);

  static Future<void> deleteSection(Section section) =>
      _database.delete('Section', where: 'id = ?', whereArgs: [section.id]);

  static Future<void> deleteQuestion(Question question) =>
      _database.delete('Question', where: 'id = ?', whereArgs: [question.id]);

  static Future<void> deleteReference(Reference reference) =>
      _database.delete('Reference', where: 'id = ?', whereArgs: [reference.id]);

  static Future<void> deleteMarker(Marker marker) =>
      _database.delete('Marker', where: 'id = ?', whereArgs: [marker.id]);

  static Future<List<MarkerAndQuestion>> getMarkerAndQuestions(
    Reference reference,
  ) async {
    List<Map<String, dynamic>> rows = await _database.rawQuery(
      'Select q.id as q_id, m.id as m_id, q.*, m.* '
      'from Question q, Marker m '
      'where q.markerId = m.id;',
    );
    return [for (var r in rows) MarkerAndQuestion.fromRow(r)];
  }
}
