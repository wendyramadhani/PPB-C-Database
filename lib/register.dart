import 'package:expense_tracker/services/database_service.dart';
import 'package:flutter/material.dart';

class RegisterApp extends StatelessWidget {
  const RegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Register();
  }
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _UserRegisterController = TextEditingController();
  final TextEditingController _PasswordRegisterController =
      TextEditingController();
  final TextEditingController _RePasswordRegisterController =
      TextEditingController();

  void checkUserData() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> result = await db.query("Users");
    print(result); // Ini akan tampil di debug console
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[300],
      body: Card(
        margin: EdgeInsets.fromLTRB(20, 270, 20, 250),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Text('Login Expense tracker App'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _UserRegisterController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _PasswordRegisterController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _RePasswordRegisterController,
                decoration: InputDecoration(
                  labelText: "Retype the Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Align(
              child: ElevatedButton(
                onPressed: () async {
                  if (_PasswordRegisterController.text !=
                      _RePasswordRegisterController.text) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Password doesn't match"),
                          content: Text("Please Retype the Password"),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop(); // menutup dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                  if (_PasswordRegisterController.text == "" ||
                      _RePasswordRegisterController.text == "" ||
                      _UserRegisterController == "") {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Field cant be empty"),
                          content: Text("please fill the field"),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop(); // menutup dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                  bool succes = await _databaseService.addUser(
                    _UserRegisterController.text,
                    _PasswordRegisterController.text,
                  );
                  if (succes == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Congratulation"),
                          content: Text("Account Registered"),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop(); // menutup dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text("Register"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Back to Login Page"),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(10), // hilangkan padding default
                  minimumSize: Size(0, 0), // hilangkan ukuran minimum default
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // buat lebih kecil
                  alignment: Alignment.centerLeft,
                  foregroundColor: Colors.blueGrey, // kalau mau rata kiri
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
