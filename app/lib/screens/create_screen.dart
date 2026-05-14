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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary, // Branding ok
              child: const Text(
                "LeagueTastic",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Neue Challenge erstellen",
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
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
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? "Bitte Name eingeben" : null,
                        onSaved: (value) => name = value!,
                      ),

                      const SizedBox(height: 20),

                      // DATE PICKER
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        onPressed: pickDateRange,
                        child: Text(
                          startDate == null
                              ? "Zeitraum auswählen"
                              : "${startDate!.toLocal()} - ${endDate!.toLocal()}",
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PRIVACY
                      DropdownButtonFormField<String>(
                        value: privacy,
                        dropdownColor: theme.cardColor,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: "Privatsphäre",
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                        ),
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
                      ),

                      const SizedBox(height: 40),

                      // SAVE BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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