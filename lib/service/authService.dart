import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;

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

  // Método para cadastrar o usuário com nome, telefone e senha
  Future<User?> cadastrar(String email, String senha, String nome, String telefone) async {
    try {
      // Criação do usuário com email e senha
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);

      // Se o usuário foi criado com sucesso, vamos atualizar o perfil
      User? user = cred.user;
      if (user != null) {
        // Atualiza o nome no perfil do usuário
        await user.updateDisplayName(nome);

        // Salva nome e telefone em campos separados no Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nome': nome,       // Salva o nome corretamente
          'telefone': telefone,  // Salva o telefone corretamente
          'email': email,      // Salva o e-mail
        });

        // Atualiza o perfil no Firebase Auth
        await user.reload();
      }
      return user;
    } catch (e) {
      print("Erro ao cadastrar: $e");
      return null;
    }
  }
}
