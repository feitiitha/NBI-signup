import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2A0A0A), // Dark reddish-brown
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF5A623), // Orange/Gold
          secondary: Color(0xFFF5A623),
          surface: Color(0xFF1E0505),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E0505).withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFF5A623), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFF5A623),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> _onRegister(Map<String, dynamic> user) async {
    try {
      await FirebaseFirestore.instance.collection('jobseekers').add({
        ...user,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _currentIndex = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to database: $e')));
    }
  }

  Future<void> _onDelete(String docId) async {
    await FirebaseFirestore.instance
        .collection('jobseekers')
        .doc(docId)
        .delete();
  }

  Future<bool> _checkEmailUnique(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('jobseekers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error validating email: $e')));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? RegisterTab(onSubmit: _onRegister, onCheckEmail: _checkEmailUnique)
          : UserListTab(onDelete: _onDelete),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E0505),
        selectedItemColor: const Color(0xFFF5A623),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        ],
      ),
    );
  }
}

class RegisterTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Future<bool> Function(String) onCheckEmail;

  const RegisterTab({
    super.key,
    required this.onSubmit,
    required this.onCheckEmail,
  });

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _motherFirstNameController =
      TextEditingController();
  final TextEditingController _motherMiddleNameController =
      TextEditingController();
  final TextEditingController _motherLastNameController =
      TextEditingController();
  String? _selectedSex;

  String? _selectedCivilStatus;
  DateTime? _birthDate;

  @override
  void dispose() {
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _motherFirstNameController.dispose();
    _motherMiddleNameController.dispose();
    _motherLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Header Icon
            const Center(
              child: Icon(Icons.account_circle, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // Header Text
            const Center(
              child: Text(
                'REGISTER AS FIRST TIME\nJOBSEEKER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Gender & Civil Status Row
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Select Sex',
                    items: ['Male', 'Female'],
                    value: _selectedSex,
                    onChanged: (val) {
                      setState(() {
                        _selectedSex = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    'Civil Status',
                    items: [
                      'SINGLE',
                      'MARRIED',
                      'SEPARATED',
                      'WIDOW',
                      'DIVORCED',
                      'ANNULLED',
                      'WIDOWER',
                      'SINGLE PARENT',
                    ],
                    value: _selectedCivilStatus,
                    onChanged: (val) {
                      setState(() {
                        _selectedCivilStatus = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Birth Date
            const Text(
              'Birth Date',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF5A623)),
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFF1E0505).withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthDate == null
                          ? '- Select Date -'
                          : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _birthDate == null
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF5A623),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name Fields
            _buildTextField(
              'First Name (Ex. DAVID JR, JOHN III)',
              controller: _firstNameController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter first name' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Middle Name (Optional)',
              controller: _middleNameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Surname',
              controller: _surnameController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter surname' : null,
            ),
            const SizedBox(height: 16),

            // Mother's Maiden Name
            const Text(
              "Mother's Maiden Name",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'First Name',
                    controller: _motherFirstNameController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    'Middle Name (Optional)',
                    controller: _motherMiddleNameController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    'Last Name',
                    controller: _motherLastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact & Account
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Mobile Number (09XXXXXXXXX)',
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter contact no.';
                if (!RegExp(r'^09\d{9}$').hasMatch(value))
                  return 'Enter valid format';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter new Email Address',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your email';
                if (!value.contains('@')) return 'Email is missing "@" symbol';
                if (!value.contains('.com')) return 'Email is missing ".com"';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter new Password',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Confirm new Password',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Terms
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptedTerms,
                    onChanged: (val) {
                      setState(() {
                        _acceptedTerms = val ?? false;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.white,
                    ),
                    checkColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'READ and ACCEPT ',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'TERMS OF SERVICES',
                          style: TextStyle(
                            color: Color(0xFFF5A623),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!_acceptedTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please accept the Terms of Services'),
                        ),
                      );
                      return;
                    }

                    // Check for duplicate email
                    final email = _emailController.text.trim();
                    final isUnique = await widget.onCheckEmail(email);

                    if (!isUnique) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email already exists. Please use a different email.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      return;
                    }

                    // Gather Data
                    final data = {
                      'firstName': _firstNameController.text,
                      'middleName': _middleNameController.text,
                      'surname': _surnameController.text,
                      'sex': _selectedSex,
                      'civilStatus': _selectedCivilStatus,
                      'birthDate': _birthDate.toString(),
                      'contact': _contactController.text,
                      'email': _emailController.text,
                    };

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text('Registration Successful'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              Text(
                                'Name: ${_firstNameController.text} ${_middleNameController.text} ${_surnameController.text}',
                              ),
                              const SizedBox(height: 4),
                              Text('Sex: ${_selectedSex ?? "N/A"}'),
                              const SizedBox(height: 4),
                              Text(
                                'Civil Status: ${_selectedCivilStatus ?? "N/A"}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Birth Date: ${_birthDate != null ? "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}" : "N/A"}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Mother's Maiden Name: ${_motherFirstNameController.text} ${_motherMiddleNameController.text} ${_motherLastNameController.text}",
                              ),
                              const SizedBox(height: 4),
                              Text('Contact: ${_contactController.text}'),
                              const SizedBox(height: 4),
                              Text('Email: ${_emailController.text}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onSubmit(data);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF5A623), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  foregroundColor: const Color(0xFFF5A623),
                ),
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(hintText: hint, isDense: true),
      validator: validator,
    );
  }

  Widget _buildDropdown(
    String hint, {
    List<String>? items,
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF5A623)),
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFF1E0505).withOpacity(0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: const Color(0xFF2A0A0A),
          items:
              items?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList() ??
              const [],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF5A623),
              onPrimary: Colors.black,
              surface: Color(0xFF2A0A0A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2A0A0A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }
}

class UserListTab extends StatelessWidget {
  final Function(String) onDelete; // Now accepts a String ID

  const UserListTab({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Registered Jobseekers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobseekers')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFF1E0505).withOpacity(0.8),
                      child: ListTile(
                        title: Text(
                          '${user['firstName']} ${user['surname']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('${user['email']}\n${user['contact']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(docId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
