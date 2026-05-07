import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';
import '../services/supabase_service.dart';

class SubmissionFormWidget extends StatefulWidget {
  final Submission? submission;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const SubmissionFormWidget({
    super.key,
    this.submission,
    required this.onSuccess,
    this.onCancel,
  });

  @override
  State<SubmissionFormWidget> createState() => _SubmissionFormWidgetState();
}

class _SubmissionFormWidgetState extends State<SubmissionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.submission?.fullName);
    _emailController = TextEditingController(text: widget.submission?.email);
    _phoneController = TextEditingController(text: widget.submission?.phoneNumber);
    _addressController = TextEditingController(text: widget.submission?.address);
    if (widget.submission != null) {
      _gender = widget.submission!.gender;
    }
  }

  @override
  void didUpdateWidget(SubmissionFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.submission != oldWidget.submission) {
      _nameController.text = widget.submission?.fullName ?? '';
      _emailController.text = widget.submission?.email ?? '';
      _phoneController.text = widget.submission?.phoneNumber ?? '';
      _addressController.text = widget.submission?.address ?? '';
      _gender = widget.submission?.gender ?? 'Male';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newSubmission = Submission(
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      gender: _gender,
    );

    try {
      if (widget.submission?.id != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              'Confirm Update',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            content: const Text(
              'Update this record in Supabase?',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'UPDATE',
                  style: TextStyle(color: Color(0xFF3ECF8E), fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        await _supabaseService.updateSubmission(widget.submission!.id!, newSubmission);
      } else {
        await _supabaseService.createSubmission(newSubmission);
      }
      widget.onSuccess();

      if (widget.submission == null) {
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          _buildTextField(_nameController, 'Abrar Hussain'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Email'),
                    _buildTextField(_emailController, 'abrar@edu.pk', isEmail: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Phone'),
                    _buildTextField(_phoneController, '+92 300 0000000'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Address'),
          _buildTextField(_addressController, 'Islamabad, Pakistan', maxLines: 2),
          const SizedBox(height: 16),
          _buildLabel('Gender Selection'),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final isSelected = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3ECF8E).withOpacity(0.1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3ECF8E) : const Color(0xFFF1F5F9),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      g.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? const Color(0xFF065F46) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      widget.submission == null ? 'SUBMIT TO SUPABASE' : 'UPDATE RECORD',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
            ),
          ),
          if (widget.onCancel != null)
            Center(
              child: TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'CANCEL AND RETURN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isEmail = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3ECF8E), width: 2)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}
