import 'package:aiche/main/blogs/model/blog_model.dart';
import 'package:aiche/main/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileUtil {
  /// Navigate to profile detail screen from any user model
  static void navigateToProfileDetail(BuildContext context,
      {User? userModel}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(userModel: userModel!),
      ),
    );
  }

  /// Navigate to profile detail from a blog's user
  static void navigateToProfileFromBlog(BuildContext context,
      {User? blogUser}) {
    if (blogUser == null) return;

    // Convert from Blog User model to UserModel
    final userModel = User(
      id: blogUser.id,
      name: blogUser.name,
      imageUrl: blogUser.imageUrl,
      bio: blogUser.bio,
      phone: blogUser.phone,
      linkedInLink: blogUser.linkedInLink,
      createdAt: blogUser.createdAt
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(userModel: userModel),
      ),
    );
  }
}
