import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'Classes/user_model.dart';


class Post {
  final String title;
  final String imageUrl;
  final String description;
  final DateTime timestamp;

  Post({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
  });
}

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref().child('Posts');
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.isNotEmpty || _selectedImage != null) {
      String? downloadUrl;
      if (_selectedImage != null) {
        // Upload the image
        firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('PostImage/${DateTime.now().toString()}');
        firebase_storage.UploadTask uploadTask = storageRef.putFile(_selectedImage!.absolute);
        await uploadTask.whenComplete(() {});
        downloadUrl = await storageRef.getDownloadURL();
      }

      // Insert the post into Firebase Realtime Database
      final postKey = _postsRef.push().key; // Generate a unique key for the post
      await _postsRef.child(postKey!).set({
        "PostId": postKey,
        "CreatedBy": Provider.of<UserDetail>(context, listen: false).userId,
        "UserName": Provider.of<UserDetail>(context, listen: false).name,
        "UserPictureUrl": Provider.of<UserDetail>(context, listen: false).picture ?? "",
        "CreatedAt": DateTime.now().toIso8601String(),
        'title': 'New Post',
        'imageUrl': downloadUrl ?? "",
        'description': _postController.text,
        'CreatedAt': DateTime.now().toIso8601String(),
      });

      Navigator.pop(context); // Return to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final userpic = Provider.of<UserDetail>(context).picture;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _createPost,
            child: const Text(
              'POST',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildUserInfo(userpic),
              const SizedBox(height: 16.0),
              _buildPostTextField(),
              const SizedBox(height: 16.0),
              _buildImagePreview(),
              const SizedBox(height: 16.0),
              _buildOptionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(String? userpic) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: userpic != "" ? NetworkImage(userpic!) : AssetImage("asset/usericon.png") as ImageProvider,
          radius: 25,
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Provider.of<UserDetail>(context).name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                _buildDropdownButton('Friends'),
                const SizedBox(width: 8.0),
                _buildDropdownButton('Album'),
                const SizedBox(width: 8.0),
                _buildDropdownButton('Off'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostTextField() {
    return TextField(
      controller: _postController,
      decoration: const InputDecoration(
        hintText: "What's on your mind?",
        border: InputBorder.none,
      ),
      maxLines: null,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildImagePreview() {
    return _selectedImage != null
        ? Card(
      elevation: 4.0,
      child: Image.file(_selectedImage!),
    )
        : Container(); // No image selected
  }

  Widget _buildDropdownButton(String text) {
    return DropdownButton<String>(
      value: text,
      items: [text].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        // Handle dropdown selection changes
      },
      underline: Container(),
    );
  }

  Widget _buildOptionList() {
    return Card(
      elevation: 2.0,
      child: Column(
        children: [
          _buildOptionItem(Icons.photo, 'Photo/Video', _pickImage),
          _buildOptionItem(Icons.tag, 'Tag People', () {}),
          _buildOptionItem(Icons.emoji_emotions, 'Feeling/Activity', () {}),
          _buildOptionItem(Icons.location_on, 'Check In', () {}),
          _buildOptionItem(Icons.videocam, 'Live Video', () {}),
          _buildOptionItem(Icons.camera, 'Camera', _pickImage),
          _buildOptionItem(Icons.gif, 'GIF', () {}),
          _buildOptionItem(Icons.event, 'Life Event', () {}),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
