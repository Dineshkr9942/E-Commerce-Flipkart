import 'package:flutter/material.dart';

class profilePage extends StatelessWidget {
  const profilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.blue.shade100,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dinesh KR",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "dineshkr9942@gmail.com",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _profileTile(
            icon: Icons.shopping_bag,
            title: "My Orders",
            subtitle: "View your order history",
            onTap: () {

            },
          ),
          _profileTile(
            icon: Icons.location_on,
            title: "Saved Addresses",
            subtitle: "Manage delivery addresses",
            onTap: () {},
          ),
          _profileTile(
            icon: Icons.payment,
            title: "Payment Methods",
            subtitle: "Cards, UPI & Wallets",
            onTap: () {},
          ),
          _profileTile(
            icon: Icons.favorite,
            title: "Wishlist",
            subtitle: "Your favorite products",
            onTap: () {},
          ),
          Divider(),
          _profileTile(
            icon: Icons.settings,
            title: "Settings",
            subtitle: "Notifications, privacy",
            onTap: () {},
          ),
          _profileTile(
            icon: Icons.help_outline,
            title: "Help Center",
            subtitle: "FAQs & support",
            onTap: () {},
          ),
          _profileTile(
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Sign out from account",
            color: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  static Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged out successfully")),
              );
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
