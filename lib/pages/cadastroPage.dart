import 'package:flutter/material.dart';
import 'package:vagacerta/pages/loginPage.dart';
import 'package:vagacerta/service/authService.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final AuthService _authService = AuthService();

  void cadastrar() async {
    String email = emailController.text;
    String senha = senhaController.text;

    var user = await _authService.cadastrar(email, senha);
    if (user != null) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Conta")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: senhaController,
              decoration: InputDecoration(labelText: "Senha", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cadastrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
