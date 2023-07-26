import 'package:flutter/material.dart';

import '../helpers/db_helper.dart';
import '../helpers/enums/gender_type_enum.dart';
import '../models/user.dart';

class UsersProvider with ChangeNotifier {
  List<User> _roommates = [];

  List<User> get roommates {
    return [..._roommates];
  }

  //get apartment by id
  Future<User> findById(String userId) async {
    final userData = await DBHelper.findUserById(userId);

    final user = User(
      id: userData['id'],
      email: userData['email'],
      firstName: userData['firstName'],
      lastName: userData['lastName'],
      password: userData['password'],
      imageUrl: userData['imageUrl'],
      dateOfBirth: userData['dateOfBirth'],
      gender: toGenderType(userData['gender']),
      description: userData['description'],
      phoneNumber: userData['phoneNumber'],
    );

    return user;
  }

  //update apartment by id
  Future<void> updateUser(String userId, User updatedUser) async {
    //map the user
    final userMap = {
      'id': updatedUser.id,
      'email': updatedUser.email,
      'firstName': updatedUser.firstName,
      'lastName': updatedUser.lastName,
      'password': updatedUser.password,
      'imageUrl': updatedUser.imageUrl,
      'dateOfBirth': updatedUser.dateOfBirth,
      'gender': updatedUser.gender.name,
      'description': updatedUser.description,
      'phoneNumber': updatedUser.phoneNumber,
    };

    await DBHelper.updateUserById(userId, userMap);

    notifyListeners();
  }

  //get all users by a list of ids
  Future<void> fetchRoommatesByIds(List<dynamic> userIds) async {
    final userData = await DBHelper.fetchRoommatesByIdsList(userIds);
    //convert the data to a list of users
    final users = userData.map(
      (user) {
        return User(
          id: user['id'],
          email: user['email'],
          firstName: user['firstName'],
          lastName: user['lastName'],
          password: user['password'],
          imageUrl: user['imageUrl'],
          dateOfBirth: user['dateOfBirth'],
          gender: toGenderType(user['gender']),
          description: user['description'],
          phoneNumber: user['phoneNumber'],
        );
      },
    ).toList();

    _roommates = users;

    notifyListeners();
  }
}
