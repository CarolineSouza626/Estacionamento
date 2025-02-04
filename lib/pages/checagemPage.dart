
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vagacerta/pages/estacionamentoPage.dart';
import 'package:vagacerta/pages/loginPage.dart';

class ChecagemPage extends StatefulWidget {
  const ChecagemPage({super.key});

  @override
  _ChecagemPageState createState() => _ChecagemPageState();
}

class _ChecagemPageState extends State<ChecagemPage> {

  // Verificar se já há usuário logado
  void verificarLogin() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Se estiver logado, navega para a EstacionamentoPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EstacionamentoPage()),
      );
    } else {
      // Se não estiver logado, navega para a LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Chama a verificação do login logo que a tela for carregada
    Future.delayed(Duration(seconds: 2), verificarLogin);  // Atraso para simular o splash screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Indicador de carregamento
      ),
    );
  }
}
