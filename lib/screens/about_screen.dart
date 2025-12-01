import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/components/project_info_card.dart';
import '../widgets/components/motivation_card.dart';
import '../widgets/components/architecture_card.dart';
import '../widgets/components/team_member_card.dart';

/// About screen displaying project information, motivation, architecture, and team.
///
/// Provides comprehensive overview of the project's purpose, implementation,
/// and the team behind it.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Team members data
  static final List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'Rafay',
      regNo: '2023491',
      role: 'Lead Developer',
      responsibilities: [
        'Complete Flutter frontend development',
        'UI/UX design and implementation',
        'Services architecture and state management',
        'Integration with C backend executables',
      ],
      icon: Icons.code,
      color: Colors.blue,
    ),
    TeamMember(
      name: 'Musa Ali',
      regNo: '2023330',
      role: 'QA Engineer & Backend Developer',
      responsibilities: [
        'Quality assurance and testing',
        'C algorithm implementation and optimization',
        'OpenMP parallelization strategies',
        'Performance benchmarking and validation',
      ],
      icon: Icons.verified,
      color: Colors.green,
    ),
    TeamMember(
      name: 'Abdullah Waheed',
      regNo: '2023048',
      role: 'Visual Designer & Documentation Lead',
      responsibilities: [
        'UI/UX visual design and guidelines',
        'Project documentation and reports',
        'Technical writing and user guides',
        'Design system and color schemes',
      ],
      icon: Icons.palette,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D1117),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Project Info Section
                const ProjectInfoCard(),
                const SizedBox(height: 24),

                // Motivation Section
                const MotivationCard(),
                const SizedBox(height: 24),

                // Architecture Section
                const ArchitectureCard(),
                const SizedBox(height: 32),

                // Team Section Header
                Row(
                  children: [
                    Icon(Icons.group, color: Colors.orange[400], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Development Team',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Computer Architecture Course Project - Fall 2025',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),

                // Team Members Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid: 3 columns on wide screens, 1 on narrow
                    final crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 3 ? 0.85 : 2.5,
                      ),
                      itemCount: _teamMembers.length,
                      itemBuilder: (context, index) {
                        return TeamMemberCard(member: _teamMembers[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Built with Flutter & C + OpenMP',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '© 2025 r4Tech. All rights reserved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
