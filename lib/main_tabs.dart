import 'package:flutter/material.dart';
import 'screens/messages_screen.dart';
import 'screens/saved_events_screen.dart';
// Removed unused imports
import 'screens/feed_screen.dart';
import 'screens/society_browser_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedScreen(),
    SocietyBrowserScreen(),
    // Placeholder for Messages
    MessagesPage(),
    const SavedEventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Home/Feed',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}
