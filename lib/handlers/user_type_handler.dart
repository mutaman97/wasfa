import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/handlers/signup_handler.dart';
import 'package:erx/screens/auth/user_type_screen.dart';
import 'package:erx/widgets/customer_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeHandler extends StatefulWidget {
  const UserTypeHandler({Key? key}) : super(key: key);

  @override
  State<UserTypeHandler> createState() => _UserTypeHandlerState();
}

class _UserTypeHandlerState extends State<UserTypeHandler> {
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _determineUserType();
  }

  Future<void> _determineUserType() async {
    final prefs = context.read<SharedPreferences>();
    String? cachedType = prefs.getString("userType");

    if (cachedType != null) {
      // Role found in SharedPreferences, proceed
      setState(() {
        _userType = cachedType;
        _isLoading = false;
      });
      return;
    }

    // If not in cache, check Firestore (Handles login on new device)
    final phoneNo = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (phoneNo == null) return;

    final collections = ['doctor', 'pharmacist', 'assistant', 'patient'];
    for (String role in collections) {
      final doc = await FirebaseFirestore.instance
          .collection(role)
          .doc(phoneNo)
          .get();
      if (doc.exists) {
        // Found their role! Save it to cache for next time.
        await prefs.setString("userType", role);
        setState(() {
          _userType = role;
          _isLoading = false;
        });
        return;
      }
    }

    // If we reach here, the user truly doesn't have a role yet
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CustomLoader();
    }

    if (_userType == null) {
      // New User: Show Role Selection
      return UserTypeScreen(
        onComplete: () {
          // Refresh the state after they select a role
          setState(() {
            _isLoading = true; // Show loader briefly
          });
          _determineUserType(); // Re-run the check
        },
      );
    } else {
      // User has a role: SignUpHandler will verify if they finished registration
      return const SignUpHandler();
    }
  }
}
