class Constants {
  static const String appName = 'Find My Roommate';
  static const String appTitle = 'FindMyRoommate';

  //fonts
  static const String ralewayFont = 'Raleway';

  //images paths
  static const String logoPath = './assets/images/logo.png';
  static const String avatarPlaceholderPath =
      './assets/images/avatar_placeholder.png';
  static const String apartmentPlaceholderPath =
      './assets/images/apartment_placeholder.png';

  //app bar texts
  static const String resetPasswordAppBarText = 'Reset Password';
  static const String addApartmentAppBarText = 'Add Apartment';
  static const String apartmentDetailsAppBarText = 'Apartment Details';
  static const String myApartmentAppBarText = 'My Apartment';
  static const String requestsReceivedAppBarText = 'Requests Received';
  static const String requestsSentAppBarText = 'Requests Sent';
  static const String editUserAppBarText = 'Edit Profile';
  static const String ownerDetailsAppBarText = 'Owner Details';
  static const String homeAppBarText = 'Home';
  static const String settingsAppBarText = 'Settings...';
  static const String statisticsAppBarText = 'Statistics';

  //intro texts
  static const String welcomeBackText =
      'Welcome Back! Login to continue your search!';
  static const String registerText = 'Welcome! Sign up to start your search!';
  static const String resetPasswordText =
      'Enter your email address to reset your password';

  //hint texts
  static const String passwordHintText = 'Password';
  static const String confirmPasswordHintText = 'Confirm Password';
  static const String searchHintText = 'Search...';

  //button texts
  static const String loginButtonText = 'Login';
  static const String registerButtonText = 'Register';
  static const String forgotPasswordButtonText = 'Send Reset Link';
  static const String forgotPasswordText = 'Forgot Password?';
  static const String registerNowText = 'Register Now';
  static const String loginNowText = 'Login Now';
  static const String addApartmentButtonText = 'Add Apartment';
  static const String saveChangesButtonText = 'Save Changes';
  static const String applyButtonText = 'Apply';
  static const String uploadPhotoButtonText = 'Upload Photo';
  static const String takePhotoButtonText = 'Take Photo';
  static const String choosePhotoButtonText = 'Choose Photo';
  static const String deleteApartmentButtonText = 'Delete Apartment';
  static const String confirmApartmentButtonText = 'Confirm Apartment';
  static const String applyForWaitingListButtonText = 'Apply for Waiting List';

  //drawer items
  static const String profileDrawerItemText = 'Profile';
  static const String myApartmentDrawerItemText = 'My Apartment';
  static const String requestsSentDrawerItemText = 'Requests Sent';
  static const String requestsReceivedDrawerItemText = 'Requests Received';
  static const String statisticsDrawerItemText = 'Statistics';
  static const String logoutDrawerItemText = 'Logout';

  //error codes
  static const String userNotFoundCodeText = 'user-not-found';
  static const String wrongPasswordCodeText = 'wrong-password';

  //messages
  static const String passwordResetText =
      'Password reset link sent! Check your email.';
  static const String registerSuccessText = 'Registration successful!';
  static const String passwordDoNotMatchText = 'Passwords do not match!';
  static const String loginSuccessText = 'Login successful!';
  static const String emailNotFoundText = 'No user found for that email.';
  static const String passwordIncorrectText =
      'Wrong password provided for that user.';
  static const String pleaseProvideEmailText = 'Please provide an email!';
  static const String pleaseProvidePasswordText = 'Please provide a password!';
  static const String noImageSelectedText = 'Please select an image!';
  static const String pleaseProvideTitleText = 'Please provide a title!';
  static const String pleaseProvidePriceText = 'Please provide a price!';
  static const String pleaseProvideValidPriceText =
      'Please provide a valid price!';
  static const String pleaseProvideLocationText = 'Please provide a location!';
  static const String pleaseProvideDescriptionText =
      'Please provide a description!';

  static const String pleaseProvideFirstNameText =
      'Please provide the first name!';
  static const String pleaseProvideLastNameText =
      'Please provide the last name!';
  static const String pleaseProvideValidAgeText = 'Please enter a valid age!';

  static const String apartmentAddedSuccessfullyText =
      'Apartment added successfully!';
  static const String apartmentAddedFailedText = 'Apartment added failed!';
  static const String apartmentDeletedSuccessfullyText =
      'Apartment deleted successfully!';
  static const String apartmentDeletedFailedText = 'Apartment deleted failed!';
  static const String apartmentUpdatedSuccessfullyText =
      'Apartment updated successfully!';
  static const String apartmentUpdatedFailedText = 'Apartment updated failed!';
  static const String profileEditedSuccessfullyText =
      'Profile edited successfully!';
  static const String errorUploadingImageText = 'Error uploading image';
  static const String errorOccuredText = 'An error occured!';
  static const String apartmentRequestedSuccessfullyText =
      'Apartment requested successfully!';
  static const String apartmentRequestedFailedText =
      'Apartment requested failed';
  static const String apartmentAlreadyRequestedText =
      'You have already requested this apartment!';
  static const String requestRemovedSuccessfullyText =
      'Request removed successfully!';
  static const String requestRemovedFailedText = 'Request removed failed!';
  static const String pleaseUploadImageText = 'Please upload image!';
  static const String emailAlreadyInUseText =
      'The email address is already in use by another account.';
  static const String weakPasswordText =
      'The password must be 6 characters long or more.';
  static const String invalidEmailText =
      'The email address is badly formatted.';
  static const String invalidAgeText = 'Age must be at least 18!';
  static const String noInternetConnectionText =
      'No internet connection! Please check your connection and try again.';
  static const String fieldsRequiredText =
      'Please provide values for all fields!';
  static const String cannotBeUndoneText =
      'This action cannot be undone, because the request has been already answered!';
  static const String fetchRequestsReceivedFailedText =
      'Fetching received requests failed!';
  static const String pleaseSelectLocationText = 'Please select a location!';
  static const String noImageUploaded = 'No image uploaded!';
  static const String pleaseProvideDateOfBirthText =
      'Please provide a date of birth!';
  static const String pleaseProvideValidNumberText =
      'Please provide a valid number!';
  static const String pleaseProvideValueText = 'Please provide a value!';
  static const String currentlyOccupiedByCannotBeGreaterThanTotalCapacityText =
      'Currently occupied by cannot be greater than total capacity!';
  static const String noRoommatesYetText = 'No roommates yet!';
  static const String pleaseSelectFacilitiesText = 'Please select facilities!';
  static const String invalidPhoneNumberText =
      'Please provide a valid phone number!';
  static const String pleaseProvidePhoneNumberText =
      'Please provide a phone number!';

  //firebase collections
  static const String usersCollection = 'users';
  static const String userImagesBucket = 'user_images';
  static const String apartmentsCollection = 'apartments';
  static const String apartmentImagesBucket = 'apartment_images';
  static const String requestsCollection = 'requests';

  //labels
  static const String titleLabel = 'Title';
  static const String priceLabel = 'Price';
  static const String locationLabel = 'Location';
  static const String facilitiesLabel = 'Facilities';
  static const String descriptionLabel = 'Description';
  static const String totalCapacityLabel = 'Total Capacity';
  static const String currentlyOcupiedLabel = 'Currently Ocupied By';

  static const String emailLabel = 'Email';
  static const String nameLabel = 'Name';
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String passwordLabel = 'Password';
  static const String ageLabel = 'Age';
  static const String genderLabel = 'Gender';
  static const String phoneNumberLabel = 'Phone Number';
  static const String birthDateLabel = 'Birth Date';

  //routes
  static const String homeScreenRoute = '/home';
  static const String addApartmentScreenRoute = '/add-apartment';
  static const String apartmentDetailsScreenRoute = '/apartment-details';
  static const String myApartmentScreenRoute = '/my-apartment';
  static const String forgotPasswordScreenRoute = '/forgot-password';
  static const String requestsReceivedScreenRoute = '/requests-received';
  static const String requestsSentScreenRoute = '/requests-sent';
  static const String editUserScreenRoute = '/edit-user';
  static const String userDetailsScreenRoute = '/user-details';
  static const String statisticsScreenRoute = '/statistics';

  //other texts
  static const String noAccountText = 'Don\'t have an account?';
  static const String alreadyHaveAccountText = 'Already have an account?';
  static const String notAMemberText = 'Not a member?';
  static const String youHaveNotAddedApartmentText =
      'You have not added an apartment yet!';
  static const String noRequestsReceivedText = 'No requests received yet.';
  static const String noRequestsSentText = 'No requests sent yet.';
  static const String falseText = 'false';
  static const String trueText = 'true';
  static const String createdAtText = 'Created at';
  static const String lastModifiedText = 'Last modified at';
  static const String noApartmentsFoundText = 'No apartments found!';
  static const String privateApartmentText =
      'Your apartment is currently private!';
  static const String makeApartmentPublicText =
      'You can make it public by tapping the lock icon from the edit screen.';
  static const String apartmentDisabledText = 'Apartment disabled';
  static const String apartmentReservedText = 'Apartment fully reserved';
  static const String apartmentReservedAtTheMomentText =
      'The owner\'s approvals reached the maximum capacity! If you apply, you will be added in the waiting list. If the agreement is canceled, you still might be able to be accepted.';

//regex expressions
  static const String phoneNumberRegex =
      r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$';
}
