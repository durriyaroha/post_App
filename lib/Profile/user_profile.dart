import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../Classes/user_model.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref().child('Users_details');
  final DatabaseReference _postsRef =
  FirebaseDatabase.instance.ref().child('Posts');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final User? _user = FirebaseAuth.instance.currentUser;
  String _userName = '';
  String _profileImageUrl = 'https://via.placeholder.com/150';
  String _coverImageUrl = 'https://via.placeholder.com/300x150';
  String _aboutDescription = "";
  final List<Post> _userPosts = [];
  final TextEditingController _aboutController = TextEditingController();

  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserProfile();
    _fetchUserPosts();
  }

  void _getCurrentUser() {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    if (_user != null) {
      try {
        final snapshot = await _usersRef.child(_user!.uid).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _userName = data['userName'] ?? _userName;
            _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
            _coverImageUrl = data['coverImageUrl'] ?? _coverImageUrl;
            _aboutDescription = data['about'] ?? '';
            _aboutController.text = _aboutDescription;
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_user != null) {
      try {
        DataSnapshot snapshot = await _postsRef
            .orderByChild('userId')
            .equalTo(_user!.uid)
            .get();
        if (snapshot.exists) {
          List<Post> loadedPosts = [];
          Map<dynamic, dynamic> postsMap =
          snapshot.value as Map<dynamic, dynamic>;
          postsMap.forEach((key, value) {
            loadedPosts.add(Post.fromMap(value));
          });

          setState(() {
            _userPosts.clear();
            _userPosts.addAll(loadedPosts);
          });
        }
      } catch (e) {
        print('Error fetching posts: $e');
      }
    }
  }

  Future<void> _pickAndUploadImage(String type) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && _user != null) {
      try {
        final ref = _storage
            .ref()
            .child('$type/${_user!.uid}/${DateTime.now()}');
        await ref.putFile(File(image.path));
        final downloadUrl = await ref.getDownloadURL();
        setState(() {
          if (type == "Cover Photo") {
            _coverImageUrl = downloadUrl;
          } else if (type == "Profile Photo") {
            _profileImageUrl = downloadUrl;
          }
        });
        await _usersRef.child(_user!.uid).update({
          type == "Cover Photo"
              ? 'coverImageUrl'
              : 'profileImageUrl': downloadUrl,
        });
      } catch (e) {
        print('Error uploading $type: $e');
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bio"),
        content: TextField(
          controller: _aboutController,
          decoration: const InputDecoration(
            labelText: 'Enter description',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _usersRef.child(_user!.uid).update({
                  'about': _aboutController.text,
                });
                setState(() {
                  _aboutDescription = _aboutController.text;
                });
              } catch (e) {
                print('Error updating bio: $e');
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String type, String imageUrl, double height,
      double width, double borderRadius) {
    return GestureDetector(
      onTap: () => _pickAndUploadImage(type),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image:
          DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer<UserDetail>(
      builder: (context, userDetailProvider, child) => Column(
        children: [
          _buildImagePicker(
            "Cover Photo",
            _coverImageUrl,
            200,
            double.infinity,
            0,
          ),
          const SizedBox(height: 8),
          _buildImagePicker(
            "Profile Photo",
            _profileImageUrl,
            100,
            100,
            50,
          ),
          const SizedBox(height: 8),
          Text(
            userDetailProvider.name ?? 'Full Name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: _showAboutDialog,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(_aboutDescription.isEmpty
                    ? 'No description available'
                    : _aboutDescription),
                trailing: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.imageUrl.isNotEmpty
                  ? NetworkImage(post.imageUrl)
                  : const AssetImage("asset/usericon.png") as ImageProvider,
            ),
            title: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(post.content),
          ),
          if (post.imageUrl.isNotEmpty)
            Image.network(post.imageUrl, fit: BoxFit.cover),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined,
                    color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Handle like functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined,
                    color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Navigate to comments section
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Handle share functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This method adds the new widget as required.
  Widget _buildSnapshotPostCard(DataSnapshot snapshot) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              snapshot.child("UserPictureUrl").value.toString() != ""
                  ? NetworkImage(snapshot.child("imageUrl").value.toString())
                  : const AssetImage("asset/usericon.png")
              as ImageProvider,
            ),
            title: Text(
              snapshot.child("UserName").value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${DateTime.parse(snapshot.child("CreatedAt").value.toString()).toLocal()}'
                  .split(' ')[0],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(snapshot.child("description").value.toString()),
          ),
          if (snapshot.child("imageUrl").value.toString().isNotEmpty)
            Image.network(
              snapshot.child("imageUrl").value.toString(),
              fit: BoxFit.cover,
            ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined,
                    color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Handle like functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined,
                    color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Navigate to comments section
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF9E1B1E)),
                onPressed: () {
                  // Handle share functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfo(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) =>
                  _buildPostCard(_userPosts[index]),
            ),
            // Fetch and display only the current user's posts
            FutureBuilder(
              future: _postsRef
                  .orderByChild('userId')
                  .equalTo(_user!.uid)
                  .get(),
              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  List<Widget> postWidgets = [];
                  Map<dynamic, dynamic> postsMap =
                  snapshot.data!.value as Map<dynamic, dynamic>;
                  postsMap.forEach((key, value) {
                    DataSnapshot postSnapshot = snapshot.data!.child(key);
                    postWidgets.add(_buildSnapshotPostCard(postSnapshot));
                  });
                  return Column(children: postWidgets);
                } else {
                  return const Text("No posts found.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String content;
  final String imageUrl;

  Post({required this.title, required this.content, this.imageUrl = ''});

  factory Post.fromMap(Map<dynamic, dynamic> data) {
    return Post(
      title: data['title'] ?? 'No Title',
      content: data['content'] ?? 'No Content',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
