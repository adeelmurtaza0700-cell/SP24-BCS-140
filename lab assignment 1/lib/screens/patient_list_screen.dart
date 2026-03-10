import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/patient_model.dart';
import 'add_patient_screen.dart';
import 'edit_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {

  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  void loadPatients() async {
    final data = await DatabaseHelper.instance.getPatients();
    setState(() {
      patients = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor App"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {

          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddPatientScreen()));

          loadPatients();
        },
      ),

      body: patients.isEmpty
          ? const Center(child: Text("No Patients Added"))
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {

                final patient = patients[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 8),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: ListTile(

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: patient.image.isNotEmpty
                          ? FileImage(File(patient.image))
                          : null,
                      child: patient.image.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    title: Text(
                      patient.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text("Disease: ${patient.disease}"),

                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PatientDetailScreen(patient: patient)));
                    },

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () async {

                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditPatientScreen(patient: patient)));

                            loadPatients();
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(

                                  title: const Text("Delete Patient"),

                                  content: const Text(
                                      "Are you sure you want to delete this patient?"),

                                  actions: [

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),

                                    TextButton(
                                      onPressed: () async {

                                        await DatabaseHelper.instance
                                            .deletePatient(patient.id!);

                                        Navigator.pop(context);

                                        loadPatients();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text("Patient Deleted")),
                                        );
                                      },

                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}