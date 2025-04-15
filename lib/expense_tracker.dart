import 'package:expense_tracker/login.dart';
import 'package:expense_tracker/models/users.dart';
import 'package:expense_tracker/register.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ExpenseTrackerApp extends StatelessWidget {
  final int uid;

  const ExpenseTrackerApp({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseTracker(uid: uid), // kirim uid ke halaman utama
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  final int uid;

  const ExpenseTracker({Key? key, required this.uid}) : super(key: key);

  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  Future<void> _fetchExpenses() async {
    print('uid = ${widget.uid}');
    final initexpenses = await _databaseService.getUserExpense(widget.uid);
    setState(() {
      expenses = initexpenses;
    });
  }

  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  List<Map<String, dynamic>> expenses = [];
  int balance = 0;

  void initbalance() async {
    int initbalance = await _databaseService.updateUserBalance(0, widget.uid);
    setState(() {
      balance = initbalance;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    initbalance();
  }

  void _setBalance(int balanceinp) async {
    if (_balanceController.text.isEmpty) return;

    balanceinp = int.tryParse(_balanceController.text) ?? 0;

    if (balanceinp != 0) {
      int newbalance = await _databaseService.updateUserBalance(
        balanceinp,
        widget.uid,
      );
      setState(() {
        balance = newbalance;
      });
      _balanceController.clear();
    }
  }

  void _showexpense() async {
    final data = await _databaseService.getUserExpense(widget.uid);
    print("Data untuk UID ${widget.uid}: $data"); // Tambahkan ini untuk debug
    setState(() {
      expenses = data;
    });
  }

  void _addExpense(String title, int amount) async {
    if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      amount = -int.parse(_amountController.text);
      title = _titleController.text;
      if (amount <= balance) {
        bool success = await _databaseService.addExpense(
          amount,
          title,
          widget.uid,
        );
        if (success == true) {
          final newBalance = balance + amount; // karena amount sudah negatif
          setState(() {
            balance = newBalance;
          });
          _showexpense(); // tambahkan ini untuk refresh list
        }

        _titleController.clear();
        _amountController.clear();
      } else {
        _showErrorDialog("Insufficient balance!");
      }
    }
  }

  //src: chatgpt untuk pop up form di edit, saya ganti pada tipedata di list nya karena pada chatgpt hanya string biasa listnya
  void _editExpense(int index) {
    final expenseId = expenses[index]['id'];
    final oldAmount = expenses[index]['amount']; // negatif

    _titleController.text = expenses[index]['title'];
    _amountController.text = (-oldAmount).toString(); // tampilkan positif

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                int updatedAmount =
                    -int.parse(
                      _amountController.text,
                    ); // simpan sebagai negatif
                String updatedTitle = _titleController.text;

                await _databaseService.updateExpenseById(
                  expenseId,
                  updatedTitle,
                  updatedAmount,
                );

                // Hitung selisih dan update balance
                int difference = (updatedAmount - oldAmount).toInt();
                setState(() {
                  balance += difference;
                });

                _titleController.clear();
                _amountController.clear();

                Navigator.pop(context);
                _showexpense();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) async {
    final expenseId = expenses[index]['id'];
    final int amount = expenses[index]['amount']; // negatif

    await _databaseService.deleteexpensebyid(expenseId);

    setState(() {
      balance -=
          amount; // karena amount negatif, -(-amount) = +pengembalian uang
    });

    _showexpense();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4, // Opsional: untuk efek bayangan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  16,
                ), // Menambahkan padding agar lebih rapi
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _balanceController,
                      decoration: InputDecoration(labelText: 'Add Balance'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _setBalance(int.parse(_balanceController.text));
                      },
                      child: Text('Add'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _addExpense(
                          _titleController.text,
                          int.parse(_amountController.text),
                        );
                      }, //_addExpense,
                      child: Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Pastikan ukuran menyesuaikan konten
                    children: [
                      Text(
                        'Remaining Balance: IDR $balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ), // Tambahkan ruang antara teks dan daftar
                      Expanded(
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.lightBlue[200],
                              child: ListTile(
                                title: Text(expenses[index]['title'] ?? ''),
                                subtitle: Text(
                                  'Amount: IDR ${-(expenses[index]['amount']) ?? 0}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editExpense(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteExpense(index);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
