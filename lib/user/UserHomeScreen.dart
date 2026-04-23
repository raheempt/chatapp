

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:chatapp/user/userloginscreen.dart';

class UserHomeScreen extends StatefulWidget {
  final String name;
  final String phone;

  const UserHomeScreen({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      /// 🔙 BACK → LOGIN SCREEN
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UserLoginScreen(),
          ),
        );
        return false; // prevent default pop
      },

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF075E54),
          title: Text("Hi, ${widget.name}"),
        ),

        body: Column(
          children: [
            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => searchText = value.toLowerCase());
                },
              ),
            ),

            /// 👥 USER LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final name =
                        doc['name'].toString().toLowerCase();
                    return name.contains(searchText);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      if (user.id == widget.phone) {
                        return const SizedBox();
                      }

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.person,
                              color: Colors.white),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['phone']),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUser: widget.phone,
                                otherUser: user.id,
                                otherName: user['name'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}