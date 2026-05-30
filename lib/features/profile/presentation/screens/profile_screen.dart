import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_controller.dart';
import 'buyer_profile_screen.dart';
import 'seller_profile_screen.dart';

/// Role-aware profile dispatcher widget that determines whether to render
/// the BuyerProfileScreen or SellerProfileScreen dynamically.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = GetIt.I<AuthController>();

    return ListenableBuilder(
      listenable: authCtrl,
      builder: (context, _) {
        final user = authCtrl.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (user.role == UserRole.seller) {
          return const SellerProfileScreen();
        } else {
          return const BuyerProfileScreen();
        }
      },
    );
  }
}
