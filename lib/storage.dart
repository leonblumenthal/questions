import 'package:path/path.dart';
import 'package:questions/models.dart';
import 'package:questions/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

class Storage {
  static const _createTables = [
    'CREATE TABLE Course('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'color INTEGER'
        ');',
    'CREATE TABLE Section('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'title TEXT,'
        'documentPath TEXT,'
        'courseId INTEGER REFERENCES Course(id) ON DELETE CASCADE'
        ');',
    'CREATE TABLE Question('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'text TEXT,'
        'streak INTEGER,'
        'lastAnswered INTEGER,'
        'x REAL,'
        'y REAL,'
        'sectionId INTEGER REFERENCES Section(id) ON DELETE CASCADE'
        ');',
    'CREATE TABLE Answer('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'correct INTEGER,'
        'dateTime INTEGER,'
        'questionId INTEGER REFERENCES Question(id) ON DELETE CASCADE'
        ');',
  ];

  static Database _database;

  static Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'questions.db'),
      onCreate: (db, version) async {
        for (var s in _createTables) await db.execute(s);
      },
      version: 1,
    );
  }

  static Future<StorageModel> insert(StorageModel model) async {
    var id = await _database.insert(
      model.tableName,
      model._toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return model..id = id;
  }

  static Future<void> delete(StorageModel model) =>
      _database.delete(model.tableName, where: 'id = ?', whereArgs: [model.id]);

  static Future<List<Course>> getCourses() => _database
      .query('Course')
      .then((v) => v.map((map) => Course().._fromMap(map)).toList());

  static Future<List<Section>> getSections(Course course) =>
      _database.query('Section', where: 'courseId = ?', whereArgs: [
        course.id ?? -1
      ]).then((v) => v.map((map) => Section().._fromMap(map)).toList());

  static Future<List<Question>> getQuestions(Section section) =>
      _database.query('Question', where: 'sectionId = ?', whereArgs: [
        section.id ?? -1
      ]).then((v) => v.map((map) => Question().._fromMap(map)).toList());

  static Future<List<Answer>> getAnswers(Question question) => _database
      .query(
        'Answer',
        where: 'questionId = ?',
        whereArgs: [question.id ?? -1],
        orderBy: 'dateTime',
      )
      .then((v) => v.map((map) => Answer().._fromMap(map)).toList());

  static Future<Course> getCourse(int id) =>
      _database.query('Course', where: 'id = ?', whereArgs: [id]).then(
        (v) => v.length == 0 ? null : Course()
          .._fromMap(v.first),
      );

  static Future<void> removeQuestionMarkers(Section section) =>
      _database.update(
        'Question',
        {'x': null, 'y': null},
        where: 'sectionId = ?',
        whereArgs: [section.id],
      );

  static Future<void> deleteAnswers(Question question) => _database
      .delete('Answer', where: 'questionId = ?', whereArgs: [question.id]);

  /// Reset all stats from questions in the section.
  static Future<void> resetQuestions(Section section) async {
    // Reset streak and last answered of section questions.
    await _database.update(
      'Question',
      {'streak': 0, 'lastAnswered': null},
      where: 'sectionId = ?',
      whereArgs: [section.id],
    );
    // Remove all section question answers.
    await _database.rawDelete(
      'DELETE FROM Answer '
      'WHERE questionId IN '
      '(SELECT id FROM Question WHERE sectionId = ?);',
      [section.id],
    );
  }

  /// Get all questions to answer from a course where streak
  /// is less than the difference of days between last answered and today.
  static Future<List<QuestionToAnswer>> getQuestionsToAnswer(
    Course course,
  ) async {
    Map<int, Section> sectionMap = {};
    for (var s in await getSections(course)) sectionMap[s.id] = s;

    var rows = await _database.rawQuery(
      'Select q.* '
      'from Question q, Section s '
      'where q.sectionId = s.id and s.courseId = ? and '
      '(q.streak <= (? - q.lastAnswered)/86400000 or q.streak = 0);',
      [course.id, getDate().millisecondsSinceEpoch],
    );

    return rows.map((r) {
      var q = Question().._fromMap(r);
      return QuestionToAnswer(q, sectionMap[q.sectionId], course);
    }).toList();
  }

  /// Get all courses with stats;
  static Future<List<CourseWithStats>> getCoursesWithStats() async {
    var rows = await _database.rawQuery(
      'Select c.*, count(q.id) as qCount, avg(q.streak) as avgStreak, '
      '(Select count(*) from Section where courseId = c.id) as sCount '
      'FROM Course c left outer join Section s on c.id = s.courseId '
      'left outer join Question q on s.id = q.sectionId '
      'GROUP BY c.id, c.title, c.color;',
    );
    return rows.map((r) {
      return CourseWithStats(
        Course().._fromMap(r),
        CourseStats(r['sCount'], r['qCount'], r['avgStreak']),
      );
    }).toList();
  }
}

abstract class StorageModel {
  int id;

  StorageModel([this.id]);

  String get tableName => this.runtimeType.toString();

  @override
  String toString() => "${this.runtimeType.toString()} $id";

  /// Convert model to map for storage.
  Map<String, dynamic> toMap();
  Map<String, dynamic> _toMap() => toMap()..['id'] = id;

  /// Fill model with map from storage.
  void fromMap(Map<String, dynamic> map);
  void _fromMap(Map<String, dynamic> map) {
    id = map['id'];
    fromMap(map);
  }
}
