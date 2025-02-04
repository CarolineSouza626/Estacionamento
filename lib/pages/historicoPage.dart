import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vagacerta/service/estacionamentoService.dart';

class HistoricoPage extends StatelessWidget {
  final EstacionamentoService _service = EstacionamentoService();

  HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Vagas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getHistoricoVagas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var historico = snapshot.data!.docs;
          return ListView.builder(
            itemCount: historico.length,
            itemBuilder: (context, index) {
              var registro = historico[index];
              var horaEntrada = (registro['hora_entrada'] as Timestamp).toDate();
              var horaSaida = registro['hora_saida'] != null ? (registro['hora_saida'] as Timestamp).toDate() : null;
              return ListTile(
                title: Text("Placa: ${registro['placa']}"),
                subtitle: Text("Entrada: $horaEntrada, Saída: $horaSaida"),
              );
            },
          );
        },
      ),
    );
  }
}
