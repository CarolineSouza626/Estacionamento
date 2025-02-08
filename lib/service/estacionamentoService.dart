import 'package:cloud_firestore/cloud_firestore.dart';

class EstacionamentoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para obter as vagas
  Stream<QuerySnapshot> getVagas() {
    return _firestore.collection('vaga').snapshots();
  }

   // Função para obter vagas filtradas por tipo de veículo (moto ou carro)
  Stream<QuerySnapshot> getVagasPorTipo(String tipo) {
    return _firestore.collection('vagas')
      .where('tipo', isEqualTo: tipo)  // Filtra pelo tipo (moto ou carro)
      .snapshots();
  }

  // Função para liberar vaga e registrar no histórico
  Future<void> liberarVaga(String id) async {
    var vaga = await _firestore.collection("vaga").doc(id).get();

    if (vaga.exists && vaga.data() != null) {
      var dados = vaga.data()!;

      if (dados["hora_entrada"] != null) {
        DateTime horaEntrada = (dados["hora_entrada"] as Timestamp).toDate();
        DateTime horaSaida = DateTime.now();
        double valor = calcularPagamento(horaEntrada, horaSaida);

        // Salvar no histórico
        await _firestore.collection("historico_vagas").add({
          "placa": dados["placa"],
          "hora_entrada": horaEntrada,
          "hora_saida": horaSaida,
          "valor_pago": valor,
        });

        // Atualizar a vaga como disponível
        await _firestore.collection("vaga").doc(id).update({
          "ocupada": false,
          "placa": null,
          "hora_entrada": null,
        });
      } else {
        print("Erro: A vaga não tem hora de entrada registrada.");
      }
    }
  }

  // Função para cadastrar o veículo na vaga
  Future<void> cadastrarVeiculoNaVaga(String id, String placa) async {
    await _firestore.collection('vaga').doc(id).update({
      'ocupada': true,
      'placa': placa,
      'hora_entrada': FieldValue.serverTimestamp(),
    });
  }

  // Retorna o histórico de vagas
  Stream<QuerySnapshot> getHistoricoVagas() {
    return _firestore.collection("historico_vagas").snapshots();
  }

  // Calcula o pagamento
  double calcularPagamento(DateTime horaEntrada, DateTime horaSaida) {
    Duration diferenca = horaSaida.difference(horaEntrada);
    int horas = (diferenca.inMinutes / 60).ceil(); // Arredonda para cima para cobrar 1 hora extra se for mais de 61 minutos
    double valorPorHora = 5.0;
    return horas * valorPorHora;
  }
   // Função para obter uma vaga pelo ID
  Future<Map<String, dynamic>?> getVagaPorId(String id) async {
    var vaga = await _firestore.collection("vaga").doc(id).get();

    if (vaga.exists) {
      return vaga.data();
    }
    return null; // Retorna null se a vaga não for encontrada
  }
}
