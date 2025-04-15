import 'package:expense_tracker/expense_tracker.dart';
import 'package:expense_tracker/models/users.dart';
import 'package:expense_tracker/register.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:flutter/material.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Login();
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _UserController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[300],
      body: Card(
        margin: EdgeInsets.fromLTRB(20, 270, 20, 270),
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
                controller: _UserController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _PasswordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Align(
              child: ElevatedButton(
                onPressed: () async {
                  if (_UserController == "" || _PasswordController == "") {
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
                  User? user = await _databaseService.loginUser(
                    _UserController.text.trim(),
                    _PasswordController.text,
                  );
                  if (user == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Login Failed"),
                          content: Text(
                            "Make sure username and password correct ",
                          ),
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
                  } else {
                    print(
                      "Logged in as: ${user.username}, Balance: ${user.balance}",
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseTrackerApp(uid: user.id!),
                      ),
                    );
                  }
                },
                child: Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterApp()),
                  );
                },
                child: Text("Register"),
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
