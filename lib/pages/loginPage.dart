import 'package:vagacerta/pages/cadastroPage.dart';
import 'package:vagacerta/service/authService.dart';
import 'package:flutter/material.dart';
import 'estacionamentoPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void login() async {
    String email = emailController.text;
    String senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var user = await _authService.login(email, senha);
    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EstacionamentoPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha no login! Verifique seus dados.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_parking, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: senhaController,
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator() // Indicador de carregamento
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Entrar"),
                    ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroPage()),
                ),
                child: Text("Criar conta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
