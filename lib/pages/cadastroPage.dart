import 'package:flutter/material.dart';
import 'package:vagacerta/pages/loginPage.dart';
import 'package:vagacerta/service/authService.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final telefoneFormatter = MaskTextInputFormatter(mask: '+55 (##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  void cadastrar() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String email = emailController.text;
      String senha = senhaController.text;
      String telefone = telefoneController.text;
      String nome = nomeController.text;

      var user = await _authService.cadastrar(email, senha, nome, telefone);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 80, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      "Cadastre-se",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField("Nome Completo", Icons.person, nomeController),
                          SizedBox(height: 15),
                          buildTextField("Telefone", Icons.phone, telefoneController, mask: telefoneFormatter),
                          SizedBox(height: 15),
                          buildTextField("Email", Icons.email, emailController, isEmail: true),
                          SizedBox(height: 15),
                          buildPasswordField("Senha", senhaController, true),
                          SizedBox(height: 15),
                          buildPasswordField("Confirmar Senha", confirmarSenhaController, false),
                          SizedBox(height: 25),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: cadastrar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text("Cadastrar"),
                                ),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text("Já tem uma conta? Faça login", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller, {bool isEmail = false, MaskTextInputFormatter? mask}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      inputFormatters: mask != null ? [mask] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Por favor, insira $label" : null,
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller, bool isMainPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isMainPassword ? !_isPasswordVisible : !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(
            isMainPassword ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off) : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              if (isMainPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Por favor, insira $label" : null,
    );
  }
}
