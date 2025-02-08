import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vagacerta/service/estacionamentoService.dart';

class HistoricoPage extends StatelessWidget {
  final EstacionamentoService _service = EstacionamentoService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Vagas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getHistoricoVagas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var historico = snapshot.data!.docs;

          if (historico.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum registro encontrado.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: historico.length,
            itemBuilder: (context, index) {
              var registro = historico[index];
              var horaEntrada = (registro['hora_entrada'] as Timestamp).toDate();
              var horaSaida = registro['hora_saida'] != null ? (registro['hora_saida'] as Timestamp).toDate() : null;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(
                    horaSaida == null ? Icons.directions_car : Icons.check_circle,
                    color: horaSaida == null ? Colors.orange : Colors.green,
                    size: 32,
                  ),
                  title: Text(
                    "Placa: ${registro['placa']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Entrada: ${_dateFormat.format(horaEntrada)}"),
                      Text("Saída: ${horaSaida != null ? _dateFormat.format(horaSaida) : 'Em aberto'}"),
                    ],
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
