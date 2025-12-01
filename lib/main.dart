import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';
import 'screens/screens.dart';
import 'widgets/widgets.dart';

void main() {
  runApp(const ProviderScope(child: ParallelArchitectureWorkbench()));
}

class ParallelArchitectureWorkbench extends StatelessWidget {
  const ParallelArchitectureWorkbench({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parallel Architecture Workbench',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Modern Technical Dark Mode
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4AA), // Deep Teal
          secondary: Color(0xFF00D4AA),
          tertiary: Color(0xFFFFB020), // Neon Amber
          surface: Color(0xFF161B22),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF161B22),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color.fromRGBO(0, 212, 170, 0.2), width: 1),
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        // Headers use monospace
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF161B22),
          titleTextStyle: GoogleFonts.jetBrainsMonoTextTheme().titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// Main navigation shell with permanent lateral rail.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  AlgoConfig? _selectedAlgo;
  final HardwareInfo _hardwareInfo = HardwareInfo.detect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) _selectedAlgo = null; // Return to dashboard
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Icon(
                Icons.developer_board,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.compare_arrows),
                label: Text('Comparison'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),

          // Vertical Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar with Hardware Context
                _buildTopBar(),

                // Content
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          HardwareInfoBadge(hardwareInfo: _hardwareInfo),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // If an algorithm is selected, show code viewer screen
    if (_selectedAlgo != null) {
      return CodeViewerScreen(algoConfig: _selectedAlgo!);
    }

    // Otherwise show navigation-based content
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onAlgoSelected: (algo) {
            setState(() => _selectedAlgo = algo);
          },
          onQuickRun: (algo) {
            setState(() => _selectedAlgo = algo);
            // TODO: Auto-start with default settings
          },
        );
      case 1:
        return const ComparisonScreen();
      case 2:
        return _buildAboutScreen();
      default:
        return _buildPlaceholder('Unknown', Icons.error);
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '$title (Coming Soon)',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutScreen() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.developer_board,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Parallel Architecture Workbench',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Text(
                'A Computer Architecture Course Project',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Visualizing parallel performance with OpenMP',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    if (_selectedAlgo != null) return _selectedAlgo!.name;

    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Comparison';
      case 2:
        return 'About';
      default:
        return 'Parallel Architecture Workbench';
    }
  }
}
