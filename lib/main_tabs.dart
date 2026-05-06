import 'package:flutter/material.dart';
import 'announcements.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'society_model.dart';

/// Bottom-nav shell that owns the three primary tabs of the app
/// (Home / Announcements / Messages) and the [SocietyNotifier] shared
/// between them.
///
/// Uses an [IndexedStack] so each tab keeps its scroll position and
/// state when the user switches away — exactly the trade-off captured by
/// MT-03 in the test plan.
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  /// Index of the active tab; matches `BottomNavigationBar.currentIndex`.
  int _currentIndex = 0;

  /// Single shared store. Both [HomePage] and [MessagesPage] point at
  /// this instance, so a join performed on the home tab is reflected on
  /// the messages tab without any explicit messaging.
  final _societyNotifier = SocietyNotifier();

  /// Built lazily in [initState] so the notifier exists before the pages
  /// are constructed.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(notifier: _societyNotifier),
      const AnnouncementHome(),
      MessagesPage(notifier: _societyNotifier),
    ];
  }

  @override
  void dispose() {
    _societyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'Announcements',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.message), label: 'Messages'),
          ],
        ),
      ),
    );
  }
}
