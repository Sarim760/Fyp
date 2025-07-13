import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../service/pdf_report.dart';

class Diagnosis extends StatefulWidget {
  const Diagnosis({super.key});



  @override
  State<Diagnosis> createState() => _DiagnosisState();
}

class _DiagnosisState extends State<Diagnosis> {
  String? _selectedPlant;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final List<String> _plants = [
    'Apple',
    'BlueBerry',
    'Cherry',
    'Corn',
    'Grape',
    'Orange',

  ];


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlantDropdown(theme),
            const SizedBox(height: 10),
            _buildImageUploadCard(theme),
            const SizedBox(height: 10),
            _buildDiagnoseButton(theme),
            const SizedBox(height: 10),
          ],
      
      ),
    );
  }
  Widget _buildPlantDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Plant',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.eco, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      value: _selectedPlant,
      items: _plants.map<DropdownMenuItem<String>>((String plant) {
        return DropdownMenuItem<String>(
          value: plant,
          child: Text(plant),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPlant = newValue;
        });
      },
    );
  }

  Widget _buildImageUploadCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              'Plant Image',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 50,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No image selected',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.camera_alt,
                        color: Theme.of(context).colorScheme.primary),
                    label: Text(
                      'Camera',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDiagnoseButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _selectedPlant == null || _selectedImage == null
          ? null
          : () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          // Generate PDF report
          final pdfFile = await PdfReportService.generateDiagnosticReport(
            plantName: _selectedPlant!,
            plantImage: _selectedImage!,
            userName: 'widget.userName',
          );

          // Close loading dialog
          if (mounted) Navigator.of(context).pop();

          // Preview the PDF
          await Printing.layoutPdf(
            onLayout: (format) => pdfFile.readAsBytes(),
          );

          // Optional: Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report generated successfully')),
          );
        } catch (e) {
          if (mounted) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating report: ${e.toString()}')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Diagnose Plant',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
