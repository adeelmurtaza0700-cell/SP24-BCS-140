// import 'dart:io';
import 'package:flutter/foundation.dart';  // For kIsWeb check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProfileCardApp());
}

class ProfileCardApp extends StatelessWidget {
  const ProfileCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B4D8)),
        useMaterial3: true,
      ),
      home: const ProfileCardScreen(),
    );
  }
}

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryDark = Color(0xFF0D1B2A);
  static const Color _secondaryDark = Color(0xFF1B2838);
  static const Color _tertiaryDark = Color(0xFF2A3F54);
  static const Color _accent = Color(0xFF00B4D8);
  static const Color _accentDark = Color(0xFF0096C7);
  static const Color _accentLight = Color(0xFF48CAE4);
  static const Color _textSecondary = Color(0xFF6B7B8D);
  static const Color _inputBg = Color(0xFFF4F7FA);
  static const Color _border = Color(0xFFE8EDF2);
  static const Color _success = Color(0xFF2ECC71);
  static const Color _danger = Color(0xFFE74C3C);

  bool _isEditing = false;
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  String _name = 'Muhammad Abrar';
  String _designation = 'Flutter Developer';
  String _email = 'abrar@example.com';
  String _phone = '+92 300 1234567';
  String _location = 'Lahore, Pakistan';
  String _bio =
      'Passionate mobile developer specializing in Flutter and cross-platform applications. Building beautiful apps one widget at a time.';

  late TextEditingController _nameCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _designationCtrl = TextEditingController(text: _designation);
    _emailCtrl = TextEditingController(text: _email);
    _phoneCtrl = TextEditingController(text: _phone);
    _locationCtrl = TextEditingController(text: _location);
    _bioCtrl = TextEditingController(text: _bio);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B2838),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: _accent),
                ),
                title: const Text('Take Photo',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.photo_library_rounded, color: _success),
                ),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _profileImage = picked;
      });
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _nameCtrl.text = _name;
      _designationCtrl.text = _designation;
      _emailCtrl.text = _email;
      _phoneCtrl.text = _phone;
      _locationCtrl.text = _location;
      _bioCtrl.text = _bio;
    });
  }

  void _saveProfile() {
    setState(() {
      _name = _nameCtrl.text.trim().isEmpty ? _name : _nameCtrl.text.trim();
      _designation = _designationCtrl.text.trim().isEmpty
          ? _designation
          : _designationCtrl.text.trim();
      _email =
          _emailCtrl.text.trim().isEmpty ? _email : _emailCtrl.text.trim();
      _phone =
          _phoneCtrl.text.trim().isEmpty ? _phone : _phoneCtrl.text.trim();
      _location = _locationCtrl.text.trim().isEmpty
          ? _location
          : _locationCtrl.text.trim();
      _bio = _bioCtrl.text.trim().isEmpty ? _bio : _bioCtrl.text.trim();
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryDark, _secondaryDark, _tertiaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentLight.withOpacity(0.06),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: _buildCard(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile Card',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        if (!_isEditing)
          _buildCircleButton(
            icon: Icons.edit_rounded,
            color: _accent,
            bgColor: _accent.withOpacity(0.15),
            onTap: _startEditing,
          )
        else
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.close_rounded,
                color: _danger,
                bgColor: _danger.withOpacity(0.15),
                onTap: _cancelEditing,
              ),
              const SizedBox(width: 10),
              _buildCircleButton(
                icon: Icons.check_rounded,
                color: Colors.white,
                bgColor: _accent,
                onTap: _saveProfile,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(),
          _buildAvatar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: _isEditing ? _buildEditForm() : _buildProfileView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          colors: [_accent, _accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: List.generate(
          6,
          (i) => Positioned(
            left: (i * 60) + 10,
            top: i % 2 == 0 ? 10 : 30,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Transform.translate(
      offset: const Offset(0, -55),
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 114,
              height: 114,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _profileImage != null
                  ? Image.network(_profileImage!.path, fit: BoxFit.cover)
                  : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_accent, _accentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 48, color: Colors.white),
                      ),
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child:
                  const Icon(Icons.camera_alt, size: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(
        children: [
          Text(
            _name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2838),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.code_rounded, size: 16, color: _accent),
                const SizedBox(width: 6),
                Text(
                  _designation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          Text(
            _bio,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          _buildContactSection(),
          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          _buildSocialSection(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildStatItem('42', 'Projects'),
          Container(width: 1, height: 30, color: _border),
          _buildStatItem('3yr', 'Experience'),
          Container(width: 1, height: 30, color: _border),
          _buildStatItem('4.9', 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B2838),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Info',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2838),
          ),
        ),
        const SizedBox(height: 12),
        _buildContactRow(Icons.mail_outline_rounded, _email, _accent),
        const SizedBox(height: 12),
        _buildContactRow(Icons.phone_rounded, _phone, _success),
        const SizedBox(height: 12),
        _buildContactRow(Icons.location_on_outlined, _location, _danger),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B2838)),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2838),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.code, const Color(0xFF333333)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.work_outline, const Color(0xFF0A66C2)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.flutter_dash, const Color(0xFF1DA1F2)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.camera_alt_outlined, const Color(0xFFE4405F)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.sports_basketball, const Color(0xFFEA4C89)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildEditForm() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(
        children: [
          _buildInputField('Full Name', _nameCtrl, Icons.person_outline),
          const SizedBox(height: 14),
          _buildInputField(
              'Designation', _designationCtrl, Icons.work_outline),
          const SizedBox(height: 14),
          _buildInputField('Email', _emailCtrl, Icons.mail_outline,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _buildInputField('Phone', _phoneCtrl, Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          _buildInputField(
              'Location', _locationCtrl, Icons.location_on_outlined),
          const SizedBox(height: 14),
          _buildInputField('Bio', _bioCtrl, Icons.info_outline, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1B2838)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: _textSecondary),
            filled: true,
            fillColor: _inputBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'CSC303 - Mobile Application Development',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Assignment 2 - Profile Card App',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}
