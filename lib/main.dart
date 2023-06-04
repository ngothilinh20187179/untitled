import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp(),
    ),
  );
}

class User {
  String id;
  String lastName, firstName, color;

  User(this.id, this.lastName, this.firstName, this.color);

  toJson() {
    return {
      "id": id,
      "color": color,
      "firstName": firstName,
      "lastName": lastName,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MyApp',
      home: UserPage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var users = <User>[];
  void add(User newUser) {
    users.add(newUser);
    notifyListeners();
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var users = appState.users;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Add new user'),
            ),
          ),
          const SizedBox(height: 15),
          users.isEmpty
              ? const Text("No Data")
              : Expanded(
            child: ListView(
              children: [
                DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Last Name')),
                      DataColumn(label: Text('First Name')),
                      DataColumn(label: Text('Color'))
                    ],
                    rows: users
                        .map(
                          (p) => DataRow(cells: [
                        DataCell(
                          Text(p.id.toString()),
                        ),
                        DataCell(
                          Text(p.lastName),
                        ),
                        DataCell(
                          Text(p.firstName),
                        ),
                        DataCell(
                          Text(p.color),
                        ),
                      ]),
                    )
                        .toList()),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          child: SignUpForm(),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _color = TextEditingController();

  final _db = FirebaseFirestore.instance;
  createUser(User user) async {
    await _db.collection("User").add(user.toJson()).whenComplete(() =>
      print("add user")
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new user'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(hintText: 'Last name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(hintText: 'First name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _color,
                decoration: const InputDecoration(hintText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String lastNameNewUser = _lastName.text;
                    String firstNameNewUser = _firstName.text;
                    String colorNewUser = _color.text;
                    User newUser = User(
                        "1", lastNameNewUser, firstNameNewUser, colorNewUser);
                    appState.add(newUser);
                    //createUser(newUser);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
