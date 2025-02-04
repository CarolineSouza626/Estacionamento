import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vagacerta/pages/historicoPage.dart';
import 'package:vagacerta/pages/loginPage.dart';
import 'package:vagacerta/service/estacionamentoService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstacionamentoPage extends StatefulWidget {
  const EstacionamentoPage({super.key});

  @override
  _EstacionamentoPageState createState() => _EstacionamentoPageState();
}

class _EstacionamentoPageState extends State<EstacionamentoPage> {
  final EstacionamentoService _service = EstacionamentoService();
  final TextEditingController placaController = TextEditingController();
  // Função para liberar vaga
  void liberarVaga(String id) async {
    // Busca os dados da vaga pelo ID
    var vaga = await _service.getVagaPorId(id);

    if (vaga != null && vaga['hora_entrada'] != null) {
      DateTime horaEntrada = (vaga['hora_entrada'] as Timestamp).toDate();
      DateTime horaSaida = DateTime.now();
      double valor = _service.calcularPagamento(horaEntrada, horaSaida);

      // Exibir um AlertDialog com o valor a ser pago
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Valor a Pagar'),
            content:
                Text('O valor a ser pago é: R\$ ${valor.toStringAsFixed(2)}'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Liberar a vaga após confirmar
                  await _service.liberarVaga(id);

                  // Fechar o diálogo
                  Navigator.of(context).pop();
                },
                child: Text('Liberar'),
              ),
              TextButton(
                onPressed: () {
                  // Fechar o diálogo sem liberar a vaga
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    } else {
      print("Erro: A vaga não tem hora de entrada registrada.");
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    // Após o logout, redireciona para a tela de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Função para cadastrar veículo na vaga
  void cadastrarVeiculo(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastrar Veículo'),
          content: TextField(
            controller: placaController,
            decoration: InputDecoration(hintText: 'Digite a placa do veículo'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cadastrar'),
              onPressed: () async {
                String placa = placaController.text;
                if (placa.isNotEmpty) {
                  // Aqui você registra o veículo na vaga e marca como ocupada
                  await _service.cadastrarVeiculoNaVaga(id, placa);
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Por favor, insira uma placa válida.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // EstacionamentoPage content dentro da EstacionamentoPage
  Widget EstacionamentoPageContent() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Cor do AppBar
        elevation: 4, // Sombra do AppBar
        title: Center(
          // Usando o Center para centralizar o título
          child: Text(
            "Gerenciamento de Estacionamento",
            style: TextStyle(
              fontSize: 20, // Tamanho do texto
              fontWeight: FontWeight.bold, // Peso do texto
              color: Colors.white, // Cor do texto
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico'),
              onTap: () {
                // Redireciona para a página de histórico
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoricoPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: logout, // Chama o método logout
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getVagas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var vagas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vagas.length,
            itemBuilder: (context, index) {
              var vaga = vagas[index];
              var horaEntrada = vaga['hora_entrada'] != null
                  ? (vaga['hora_entrada'] as Timestamp).toDate()
                  : null;
              return Card(
                elevation: 3,
                margin: EdgeInsets.all(10),
                color: vaga['ocupada']
                    ? Colors.red.shade50
                    : Colors
                        .green.shade50, // Cor diferente para ocupada/disponível
                child: ListTile(
                  title: Text("Placa: ${vaga['placa'] ?? 'Vaga Livre'}"),
                  subtitle: horaEntrada != null
                      ? Text("Entrada: ${horaEntrada.toString()}")
                      : Text("Disponível"),
                  trailing: vaga['ocupada']
                      ? ElevatedButton(
                          onPressed: () => liberarVaga(vaga.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text("Liberar"),
                        )
                      : ElevatedButton(
                          onPressed: () => cadastrarVeiculo(vaga.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text("Cadastrar Veículo"),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EstacionamentoPageContent(); // Exibe o conteúdo diretamente
  }
}
