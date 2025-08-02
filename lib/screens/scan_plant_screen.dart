import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import '../service/pdf_report.dart';

class ScanPlantScreen extends StatefulWidget {
  const ScanPlantScreen({super.key});

  @override
  State<ScanPlantScreen> createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plant'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlantDropdown(theme),
            const SizedBox(height: 20),
            _buildImageUploadCard(theme),
            const SizedBox(height: 20),
            _buildDiagnoseButton(theme),
          ],
        ),
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
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
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No image selected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                  userName: 'User', // You can get this from user session
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}