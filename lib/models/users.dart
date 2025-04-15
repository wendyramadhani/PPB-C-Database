class User {
  final int? id;
  final String username;
  final String password;
  final int balance;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.balance,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      balance:
          map['amount'], // atau map['balance'] sesuai nama kolom di tabel kamu
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'amount': balance,
    };
  }
}
