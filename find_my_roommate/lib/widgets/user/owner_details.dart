import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../helpers/convertor.dart';
import '../../models/user.dart';
import '../pickers/user_image_picker.dart';
import '../../providers/users_provider.dart';

class OwnerDetails extends StatelessWidget {
  final String ownerId;
  const OwnerDetails(this.ownerId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<UsersProvider>(context, listen: false).findById(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final loadedUser = snapshot.data as User;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserImagePicker(
                  (_) {},
                  selectedImage: NetworkImage(loadedUser.imageUrl),
                  editMode: false,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${loadedUser.lastName} ${loadedUser.firstName}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(
                  color: Colors.grey,
                  height: 0.5,
                  thickness: 0.5,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                              '${Constants.emailLabel}:', loadedUser.email),
                          const SizedBox(height: 16),
                          _buildInfoRow('${Constants.phoneNumberLabel}:',
                              loadedUser.phoneNumber),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('${Constants.ageLabel}:',
                              calculateAge(loadedUser.dateOfBirth.toDate())),
                          const SizedBox(height: 16),
                          _buildInfoRow('${Constants.genderLabel}:',
                              loadedUser.gender.name),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(
                  color: Colors.grey,
                  height: 0.5,
                  thickness: 0.5,
                ),
                const SizedBox(height: 20),
                const Text(
                  '${Constants.descriptionLabel}:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  loadedUser.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
