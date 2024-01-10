import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> fetchData(String username, String password) async {
    try {
      final key = 'cle_secrete';
      final encryptedUsername = encryptAES(username, key);
      final encryptedPassword = encryptAES(password, key);

      final response = await http.get(Uri.parse('http://193.38.250.113:3000/utilisateurs?username=$encryptedUsername&password=$encryptedPassword'));

      if (response.statusCode == 200) {
        final decodedResponse = response.body;
        print('Réponse du serveur : $decodedResponse');
      } else {
        print('Erreur de requête : ${response.statusCode}');
        throw Exception('Erreur de requête : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur de connexion: $error');
      throw Exception('Erreur de connexion: $error');
    }
  }

  String encryptAES(String data, String key) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = List<int>.from(bytes.map((e) => e ^ keyBytes[0]));

    return base64.encode(encrypted);
  }

  void _incrementCounter() {
    setState(() {
      fetchData(usernameController.text, passwordController.text).catchError((error) {
        print('Erreur dans fetchData: $error');
      });
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Masquer le mot de passe en affichant des points
            ),
            const SizedBox(height: 16),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
