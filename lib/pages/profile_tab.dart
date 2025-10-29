import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;
  File? _selectedImage;

  final picker = ImagePicker();
  final String imgbbApiKey = "cdd0523012612878dfb4019a42120671";

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        userData = data;
        nameController.text = data['name'] ?? '';
        surnameController.text = data['surname'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<String?> uploadImageToImgbb(File imageFile) async {
    try {
      var uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      var jsonData = json.decode(resBody);
      return jsonData['data']['url'];
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> pickProfileImage() async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.cyanAccent),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (picked != null)
                  setState(() => _selectedImage = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.cyanAccent,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (picked != null)
                  setState(() => _selectedImage = File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl = userData?['profileImage'];
    if (_selectedImage != null) {
      imageUrl = await uploadImageToImgbb(_selectedImage!);
    }

    Map<String, dynamic> updateData = {
      "name": nameController.text.trim(),
      "surname": surnameController.text.trim(),
      "phone": phoneController.text.trim(),
      "profileImage": imageUrl ?? '',
      "timestamp": Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(updateData, SetOptions(merge: true));

    setState(() {
      isEditing = false;
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profile updated successfully.')),
    );

    fetchUserDetails();
  }

  BoxDecoration get gradientBox => const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  Widget buildProfileImage() {
    ImageProvider? imageProvider;

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (userData?['profileImage'] != null &&
        userData!['profileImage'].toString().isNotEmpty) {
      imageProvider = NetworkImage(userData!['profileImage']);
    }

    return GestureDetector(
      onTap: isEditing ? pickProfileImage : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFF00BFA5)],
              ),
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: Colors.cyanAccent,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${nameController.text} ${surnameController.text}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          Text(
            emailController.text,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
        ),
        child: TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.cyanAccent),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: enabled ? 1 : 0.6,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFF00BFA5)],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          color: enabled ? null : Colors.grey.shade700,
        ),
        child: ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: 22),
          label: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(decoration: gradientBox),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: gradientBox,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildProfileImage(),
                          const SizedBox(height: 30),
                          isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: buildTextField(
                                        "First Name",
                                        nameController,
                                        Icons.person,
                                        isEditing,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: buildTextField(
                                        "Surname",
                                        surnameController,
                                        Icons.person_outline,
                                        isEditing,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    buildTextField(
                                      "First Name",
                                      nameController,
                                      Icons.person,
                                      isEditing,
                                    ),
                                    buildTextField(
                                      "Surname",
                                      surnameController,
                                      Icons.person_outline,
                                      isEditing,
                                    ),
                                  ],
                                ),
                          buildTextField(
                            "Phone Number",
                            phoneController,
                            Icons.phone,
                            isEditing,
                          ),
                          buildTextField(
                            "Email",
                            emailController,
                            Icons.email,
                            false,
                          ),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              Expanded(
                                child: buildGradientButton(
                                  text: isEditing ? 'Cancel' : 'Edit',
                                  icon: isEditing ? Icons.close : Icons.edit,
                                  onPressed: () {
                                    setState(() {
                                      if (isEditing) {
                                        isEditing = false;
                                        _selectedImage = null;
                                        fetchUserDetails();
                                      } else {
                                        isEditing = true;
                                      }
                                    });
                                  },
                                  enabled: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildGradientButton(
                                  text: 'Submit',
                                  icon: Icons.check,
                                  onPressed: updateProfile,
                                  enabled: isEditing,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
