import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'edulearn.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Create Courses table
    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        instructorId TEXT NOT NULL,
        instructorName TEXT NOT NULL,
        totalLessons INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        progress REAL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (instructorId) REFERENCES users(id)
      )
    ''');

    // Create CourseStudents table (many-to-many relationship)
    await db.execute('''
      CREATE TABLE course_students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses(id),
        FOREIGN KEY (studentId) REFERENCES users(id),
        UNIQUE(courseId, studentId)
      )
    ''');

    // Create Lessons table
    await db.execute('''
      CREATE TABLE lessons(
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        lessonOrder INTEGER NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        isLocked INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses(id)
      )
    ''');

    // Create StudentProgress table
    await db.execute('''
      CREATE TABLE student_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        lessonId TEXT NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (studentId) REFERENCES users(id),
        FOREIGN KEY (lessonId) REFERENCES lessons(id),
        UNIQUE(studentId, lessonId)
      )
    ''');
  }

  // Insert initial data for testing
  Future<void> insertInitialData() async {
    final db = await database;

    // Insert sample users
    await db.insert('users', {
      'id': 'staff1',
      'name': 'Prof. Smith',
      'email': 'smith@university.com',
      'role': 'staff'
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('users', {
      'id': 'staff2',
      'name': 'Dr. Johnson',
      'email': 'johnson@university.com',
      'role': 'staff'
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('users', {
      'id': 'student1',
      'name': 'Alice Johnson',
      'email': 'alice@example.com',
      'role': 'student'
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('users', {
      'id': 'student2',
      'name': 'Bob Williams',
      'email': 'bob@example.com',
      'role': 'student'
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('student_progress');
    await db.delete('lessons');
    await db.delete('course_students');
    await db.delete('courses');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}