import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientDetailScreen extends StatelessWidget {

  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Details")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            children: [

              CircleAvatar(
                radius: 60,
                backgroundImage: patient.image.isNotEmpty
                    ? FileImage(File(patient.image))
                    : null,
                child: patient.image.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),

              const SizedBox(height: 25),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Name"),
                  subtitle: Text(patient.name),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text("Age"),
                  subtitle: Text(patient.age),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone"),
                  subtitle: Text(patient.phone),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text("Disease"),
                  subtitle: Text(patient.disease),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}