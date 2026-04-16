import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  DateTime? startDate;
  DateTime? endDate;
  String privacy = "Public";

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void saveChallenge() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print("Name: $name");
      print("Start: $startDate");
      print("End: $endDate");
      print("Privacy: $privacy");

      // TODO: Firebase speichern
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "VeloLeague",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Neue Challenge erstellen",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // NAME
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? "Bitte Name eingeben" : null,
                        onSaved: (value) => name = value!,
                      ),

                      const SizedBox(height: 20),

                      // DATE PICKER
                      ElevatedButton(
                        onPressed: pickDateRange,
                        child: Text(
                          startDate == null
                              ? "Zeitraum auswählen"
                              : "${startDate!.toLocal()} - ${endDate!.toLocal()}",
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PRIVACY
                      DropdownButtonFormField(
                        dropdownColor: AppColors.background,
                        value: privacy,
                        items: const [
                          DropdownMenuItem(
                            value: "Public",
                            child: Text("Public"),
                          ),
                          DropdownMenuItem(
                            value: "Private",
                            child: Text("Private"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            privacy = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Privatsphäre",
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // SAVE BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: saveChallenge,
                        child: const Text("Speichern"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}