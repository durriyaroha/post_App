import 'dart:io';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:post_app/Classes/user_model.dart';
import 'CreatePostScreen.dart';
import 'Profile/user_profile.dart';
import 'SignInScreen.dart';
import 'auth_sevices.dart';

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

  factory Post.fromMap(Map<dynamic, dynamic> map) {
    return Post(
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      timestamp:
          DateTime.parse(map['CreatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Post> _posts = [];
  final DatabaseReference _postsRef =
      FirebaseDatabase.instance.ref().child('Posts');
  final ref = FirebaseDatabase.instance.ref('User');
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _fetchPosts() async {
    try {
      DataSnapshot snapshot = await _postsRef.get();
      if (snapshot.exists) {
        List<Post> loadedPosts = [];
        Map<dynamic, dynamic> postsMap =
            snapshot.value as Map<dynamic, dynamic>;
        postsMap.forEach((key, value) {
          loadedPosts.add(Post.fromMap(value));
        });

        setState(() {
          _posts.clear();
          _posts.addAll(loadedPosts);
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userpic = Provider.of<UserDetail>(context, listen: false).picture;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF9E1B1E), // Deep red color
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<UserDetail>(
          builder: (context, userdetailprovider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userdetailprovider.name ?? 'Full Name'),
                accountEmail:
                    Text(userdetailprovider.email ?? 'user@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: userdetailprovider.picture != null && userdetailprovider.picture!.isNotEmpty
                      ? NetworkImage(userdetailprovider.picture!)
                      : AssetImage('assets/usericon.png'),
                  child: userdetailprovider.picture == null || userdetailprovider.picture!.isEmpty
                      ? Text(
                    'P', // Fallback initial letter or icon when no picture is available
                    style: TextStyle(fontSize: 24),
                  )
                      : null,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF9E1B1E), // Deep red color
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.black),
                title: Text('Home', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.create, color: Colors.black),
                title:
                    Text('Create Post', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePostScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title:
                    Text('User Profile', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfilePage()),
                  );
                },
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.black),
                title: Text('Sign Out', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  try {
                    print('signout called');
                    //final authService = Provider.of<AuthService>(context, listen: false);
                    //await authService.signOut();
                    AuthService().signOut();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen()));
                  } catch (e) {
                    print('Error during sign-out navigation: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWhatsOnYourMindSection(),
            Expanded(
              child: FirebaseAnimatedList(
                query: _postsRef.orderByChild("CreatedAt"),
                itemBuilder: (context, snapshot, animation, index) {
                  return showPost(snapshot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showPost(DataSnapshot snapshot) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: snapshot
                          .child("UserPictureUrl")
                          .value
                          .toString() !=
                      ""
                  ? NetworkImage(snapshot.child("imageUrl").value.toString())
                  : AssetImage("asset/usericon.png") as ImageProvider,
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
                icon:
                    const Icon(Icons.share_outlined, color: Color(0xFF9E1B1E)),
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

  Widget _buildWhatsOnYourMindSection() {
    final userpic = Provider.of<UserDetail>(context, listen: false).picture;
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: userpic != ""
              ? NetworkImage(userpic!)
              : AssetImage("asset/usericon.png") as ImageProvider,
        ),
        title: GestureDetector(
          onTap: () async {
            final newPost = await Navigator.push<Post>(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(),
              ),
            );

            if (newPost != null) {
              setState(() {
                _posts.add(newPost);
              });
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              user?.displayName ?? "What's on your mind?",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.photo, color: Color(0xFF9E1B1E)),
          onPressed: () async {
            final newPost = await Navigator.push<Post>(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(),
              ),
            );

            if (newPost != null) {
              setState(() {
                _posts.add(newPost);
              });
            }
          },
        ),
      ),
    );
  }
}
