import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jobs_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY,
        name TEXT,
        detail TEXT,
        price TEXT,
        image TEXT,
        quantity TEXT,
        adminId TEXT,
        type TEXT,
        location TEXT,
        timestamp INTEGER,
        vacancies TEXT,
        experience TEXT
      )
    ''');
  }

  Future<void> insertJobs(List<Map<String, dynamic>> jobs) async {
    final db = await database;
    Batch batch = db.batch();
    for (var job in jobs) {
      batch.insert(
        'jobs',
        {
          'id': job['id'],
          'name': job['name'],
          'detail': job['detail'],
          'price': job['price'].toString(),
          'image': job['image'],
          'quantity': job['quantity'].toString(),
          'adminId': job['adminId'],
          'type': job['type'],
          'location': job['location'],
          'timestamp':
              (job['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
          'vacancies': job['vacancies'].toString(),
          'experience': job['experience'].toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jobs');
    return maps.map((map) {
      return {
        'id': map['id'],
        'name': map['name'],
        'detail': map['detail'],
        'price': map['price'],
        'image': map['image'],
        'quantity': map['quantity'],
        'adminId': map['adminId'],
        'type': map['type'],
        'location': map['location'],
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(map['timestamp']),
        'vacancies': map['vacancies'],
        'experience': map['experience'],
      };
    }).toList();
  }

  Future<void> clearJobs() async {
    final db = await database;
    await db.delete('jobs');
  }
}
