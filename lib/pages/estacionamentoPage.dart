import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vagacerta/pages/historicoPage.dart';
import 'package:vagacerta/pages/loginPage.dart';
import 'package:vagacerta/service/estacionamentoService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EstacionamentoPage extends StatefulWidget {
  const EstacionamentoPage({super.key});

  @override
  _EstacionamentoPageState createState() => _EstacionamentoPageState();
}

class _EstacionamentoPageState extends State<EstacionamentoPage> {
  final EstacionamentoService _service = EstacionamentoService();
  final TextEditingController placaController = TextEditingController();

  User? get usuarioAtual => FirebaseAuth.instance.currentUser;

  // Validação de placa
  bool _isPlacaValida(String placa) {
    final placaRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$'); // Padrão de placa
    return placaRegex.hasMatch(placa);
  }

  // Função para obter a foto de perfil
  Future<Widget> _getUserProfilePicture() async {
    try {
      if (usuarioAtual != null) {
        // Foto de perfil no Firebase Auth
        final photoUrl = usuarioAtual?.photoURL;
        if (photoUrl != null) {
          return Image.network(photoUrl, width: 50, height: 50);
        }
      }
    } catch (e) {
      print("Erro ao carregar a foto do perfil: $e");
    }
    return const CircleAvatar(child: Icon(Icons.person, size: 40)); // Foto padrão
  }

  // Função para liberar vaga
  void liberarVaga(String id) async {
    var vaga = await _service.getVagaPorId(id);
    if (vaga != null && vaga['hora_entrada'] != null) {
      DateTime horaEntrada = (vaga['hora_entrada'] as Timestamp).toDate();
      DateTime horaSaida = DateTime.now();
      double valor = _service.calcularPagamento(horaEntrada, horaSaida);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Valor a Pagar'),
          content: Text('O valor a ser pago é: R\$ ${valor.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () async {
                await _service.liberarVaga(id);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Liberar', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    }
  }

  // Função para cadastrar ou editar veículo
  void cadastrarVeiculo(String id, {String? placaAtual}) async {
    placaController.text = placaAtual ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(placaAtual != null ? 'Editar Placa' : 'Cadastrar Veículo'),
        content: TextField(
          controller: placaController,
          decoration: const InputDecoration(hintText: 'Digite a placa do veículo'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              String placa = placaController.text;
              if (placa.isNotEmpty && _isPlacaValida(placa)) {
                await _service.cadastrarVeiculoNaVaga(id, placa);
                placaController.clear(); // Limpar campo após cadastro
                Navigator.of(context).pop();
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Placa inválida. Tente novamente.")),
                );
              }
            },
            child: Text(placaAtual != null ? 'Editar' : 'Cadastrar'),
          ),
        ],
      ),
    );
  }

  // Função de logout
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciamento de Estacionamento"),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(usuarioAtual?.displayName ?? "Usuário"),
              accountEmail: Text(usuarioAtual?.email ?? "Sem e-mail"),
              currentAccountPicture: FutureBuilder<Widget>(
                future: _getUserProfilePicture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(child: CircularProgressIndicator());
                  }
                  return snapshot.data ?? const CircleAvatar(child: Icon(Icons.person));
                },
              ),
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoricoPage()),
                );
              },
            ),
        
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getVagas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var vagas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vagas.length,
            itemBuilder: (context, index) {
              var vaga = vagas[index];
              var ocupada = vaga['ocupada'] ?? false;
              var placa = vaga['placa'];
              var horaEntrada = vaga['hora_entrada'] != null
                  ? (vaga['hora_entrada'] as Timestamp).toDate()
                  : null;

              return Card(
                elevation: 6,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: ocupada ? Colors.red.shade100 : Colors.green.shade100,
                child: ListTile(
                  leading: ocupada
                      ? const Icon(Icons.directions_car, color: Colors.red)
                      : const Icon(Icons.local_parking, color: Colors.green),
                  title: Text(placa ?? 'Vaga Livre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: horaEntrada != null
                      ? Text("Entrada: ${DateFormat('dd/MM/yyyy HH:mm').format(horaEntrada)}")
                      : const Text("Disponível"),
                  trailing: ocupada
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => cadastrarVeiculo(vaga.id, placaAtual: placa),
                            ),
                            ElevatedButton(
                              onPressed: () => liberarVaga(vaga.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("Liberar"),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () => cadastrarVeiculo(vaga.id),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Cadastrar"),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
