/* import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nofliesynck/components/animated_fab.dart';
import 'package:nofliesynck/components/app_bar.dart';
import 'package:nofliesynck/components/bottom_actions.dart';
import 'package:nofliesynck/components/header.dart';
import 'package:nofliesynck/components/loading_indicator.dart';
import 'package:nofliesynck/components/notification_panel.dart';
import 'package:nofliesynck/components/presentations/system_overview_card.dart';
import 'package:nofliesynck/components/quick_action_dialog.dart';
import 'package:nofliesynck/components/quick_actions.dart';
import 'package:nofliesynck/components/recent_activity.dart';
import 'package:nofliesynck/components/system_overview.dart';
import 'package:nofliesynck/helpers/animated_background.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;
  //final MemoryService memoryService;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            widget.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        appBar: CustomAppBar(
          isDark: widget.isDark,
          toggleTheme: widget.toggleTheme,
          onNotificationTap: _showNotificationPanel,
        ),
        body: AnimatedBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    if (_isLoading)
                      const LoadingIndicator()
                    else ...[
                      const StatusOverview(),
                      const QuickActionsPanel(),
                      const SystemOverviewSection(),
                      const RecentActivitySection(),
                      const BottomActionsPanel(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedFloatingActionButton(
          fadeAnimation: _fadeAnimation,
          onPressed: _showQuickActionDialog,
        ),
      ),
    );
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  void _showQuickActionDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickActionDialog(),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nofliesynck/components/animated_fab.dart';
import 'package:nofliesynck/components/app_bar.dart';
import 'package:nofliesynck/components/bottom_actions.dart';
import 'package:nofliesynck/components/header.dart';
import 'package:nofliesynck/components/loading_indicator.dart';
import 'package:nofliesynck/components/notification_panel.dart';
import 'package:nofliesynck/components/presentations/system_overview_card.dart';
import 'package:nofliesynck/components/quick_action_dialog.dart';
import 'package:nofliesynck/components/quick_actions.dart';
import 'package:nofliesynck/components/recent_activity.dart';
import 'package:nofliesynck/components/system_overview.dart';
import 'package:nofliesynck/helpers/animated_background.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: widget.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          isDark: widget.isDark,
          toggleTheme: widget.toggleTheme,
          onNotificationTap: _showNotificationPanel,
        ),
        body: AnimatedBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: colorScheme.primary,
                color: colorScheme.onPrimary,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HomeHeader(),
                            const SizedBox(height: 16),
                            _buildLoadingOrContent(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedFloatingActionButton(
          fadeAnimation: _fadeAnimation,
          onPressed: _showQuickActionDialog,
        ),
      ),
    );
  }

  Widget _buildLoadingOrContent() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusOverview(),
        const SizedBox(height: 16),
        const QuickActionsPanel(),
        const SizedBox(height: 16),
        const SystemOverviewSection(),
        const SizedBox(height: 16),
        const RecentActivitySection(),
        const SizedBox(height: 16),
        const BottomActionsPanel(),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  void _showQuickActionDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickActionDialog(),
    );
  }
}