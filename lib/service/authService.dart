import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para login com email e senha
  Future<User?> login(String email, String senha) async {
    try {
      UserCredential cred =
          await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return cred.user;
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  // Método para logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> cadastrar(String email, String senha) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);
      return cred.user;
    } catch (e) {
      print("Erro ao cadastrar: $e");
      return null;
    }
  }
}
