import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model for team member information.
class TeamMember {
  final String name;
  final String regNo;
  final String role;
  final List<String> responsibilities;
  final IconData icon;
  final Color color;

  const TeamMember({
    required this.name,
    required this.regNo,
    required this.role,
    required this.responsibilities,
    required this.icon,
    required this.color,
  });
}

/// Card displaying team member information.
class TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const TeamMemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              member.color.withOpacity(0.1),
              member.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: member.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(member.icon, color: member.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reg: ${member.regNo}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: member.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: member.color.withOpacity(0.5)),
                ),
                child: Text(
                  member.role,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: member.color,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsibilities
              ...member.responsibilities.map(
                (responsibility) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: member.color.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          responsibility,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
