class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilePicture;
// ! simple Constructor
  UserModel(
      {required this.uid,
      required this.fullName,
      required this.email,
      required this.profilePicture});

//  !  will be Used to change your Map/Json data into UserModel
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    profilePicture = map["profilePicture"];
  }

//  !  will be Used to change your UserModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "profilePicture": profilePicture,
    };
  }
}
