
import 'package:chatapp/admin/addUserScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🌈 BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 149, 165, 238), Color.fromARGB(255, 229, 218, 240)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              /// 🔝 TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Admin Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 30),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 📦 USER LIST CARD
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No users found"));
                      }

                      final users = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Icon(Icons.person,
                                    color: Colors.white),
                              ),
                              title: Text(
                                user['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(user['phone']),

                              /// 🔥 PHONE AS ID
                              trailing: Text(
                                user.id,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ➕ FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 149, 164, 235),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddUserScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add User"),
      ),
    );
  }
}