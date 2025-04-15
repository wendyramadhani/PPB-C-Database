import 'package:expense_tracker/models/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  final String _expensetablename = "Expenses";
  final String _id = "id INTEGER PRIMARY KEY AUTOINCREMENT";
  final String amount = "amount";
  final String title = "title";
  final String date = "date";
  final String usertablename = "Users";
  final String username = "username";
  final String pass = "password";
  final String balancetablename = "balance";
  final String balanceamaount = "amount";

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
    }
    return _db!;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> getDatabase() async {
    final databasedirpath = await getDatabasesPath();
    final databasepath = join(databasedirpath, "expense_tracker6.db");
    final database = await openDatabase(
      databasepath,
      onConfigure: _onConfigure,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          '''CREATE TABLE $usertablename ($_id,$username TEXT,$pass TEXT,$balanceamaount INTEGER);''',
        );
        print('Creating tables...');
        db.execute(
          '''CREATE TABLE $_expensetablename ($_id,uid INTEGER,$amount INTEGER,$title TEXT,  FOREIGN KEY (uid) REFERENCES $usertablename(id) ON DELETE CASCADE);''',
        );

        print('Tables created.');
      },
    );
    return database;
  }

  Future<bool> addUser(String user, String pw) async {
    try {
      final db = await database;
      int id = await db.insert(usertablename, {
        username: user,
        pass: pw,
        balanceamaount: 0,
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<bool> addExpense(int examount, String titleinp, int uid) async {
    try {
      final db = await database;
      int success = await db.insert(_expensetablename, {
        'uid': uid,
        title: titleinp,
        amount: examount,
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int> updateUserBalance(int balance, int uid) async {
    final db = await database;

    final List<Map<String, dynamic>> oldAmount = await db.query(
      usertablename,
      columns: ['amount'],
      where: 'id = ?',
      whereArgs: [uid],
    );

    // Pastikan ada data dulu
    if (oldAmount.isEmpty) {
      throw Exception("User with ID $uid not found.");
    }

    int newAmount = oldAmount.first['amount'] + balance;

    await db.update(
      usertablename,
      {balanceamaount: newAmount}, // perhatikan: map diletakkan di awal
      where: 'id = ?',
      whereArgs: [uid],
    );

    return newAmount;
  }

  Future<List<Map<String, dynamic>>> getUserExpense(int uid) async {
    final db = await database;
    final List<Map<String, dynamic>> oldAmount = await db.query(
      _expensetablename,
      columns: ['id', 'title', 'amount'],
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return oldAmount;
  }

  Future<void> updateExpenseById(
    int expenseId,
    String newTitle,
    int newAmount,
  ) async {
    print(
      'Updating expense id $expenseId with title=$newTitle, amount=$newAmount',
    );
    final db = await database;

    int count = await db.update(
      _expensetablename, // Ganti sesuai nama tabelmu
      {title: newTitle, amount: newAmount},
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }

  Future<void> deleteexpensebyid(int idexpense) async {
    final db = await database;
    await db.delete(_expensetablename, where: 'id = ?', whereArgs: [idexpense]);
  }
}
