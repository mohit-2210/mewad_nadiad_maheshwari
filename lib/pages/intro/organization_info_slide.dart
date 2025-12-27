import 'package:flutter/material.dart';

/// Beautiful organization info slide that adapts to all screen sizes
class OrganizationInfoSlide extends StatelessWidget {
  const OrganizationInfoSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final titleSize = screenWidth * 0.055; // ~5.5% of screen width
    final subtitleSize = screenWidth * 0.045;
    final nameSize = screenWidth * 0.04;
    final labelSize = screenWidth * 0.035;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative top element
              Icon(
                Icons.account_balance,
                size: screenWidth * 0.15,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              SizedBox(height: screenHeight * 0.03),
              
              // Main heading with decorative underline
              Column(
                children: [
                  Text(
                    'माहेश्वरी सेवा समाज केन्द्र',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize.clamp(20.0, 32.0),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    '(महेश वाटिका)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleSize.clamp(16.0, 24.0),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Container(
                    width: screenWidth * 0.3,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.primary,
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // First organization card
              _buildOrganizationCard(
                context: context,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'जगदीशचंद्र लड्ढा'},
                  {'label': 'मंत्री', 'name': 'रामकुमार समदानी'},
                ],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                nameSize: nameSize,
                labelSize: labelSize,
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Second organization heading
              Text(
                'माहेश्वरी सेवा समिति',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize.clamp(20.0, 32.0),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.4,
                  letterSpacing: 0.5,
                ),
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Second organization card
              _buildOrganizationCard(
                context: context,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'आनंदीलाल हेड़ा'},
                  {'label': 'मंत्री', 'name': 'अशोककुमार मंडोवरा'},
                ],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                nameSize: nameSize,
                labelSize: labelSize,
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Decorative bottom element
              Icon(
                Icons.groups,
                size: screenWidth * 0.12,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCard({
    required BuildContext context,
    required List<Map<String, String>> members,
    required double screenWidth,
    required double screenHeight,
    required double nameSize,
    required double labelSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.025,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: members.map((member) {
          final isFirst = members.first == member;
          return Column(
            children: [
              if (!isFirst) SizedBox(height: screenHeight * 0.02),
              if (!isFirst)
                Divider(
                  color: Colors.grey[300],
                  height: screenHeight * 0.02,
                ),
              if (!isFirst) SizedBox(height: screenHeight * 0.02),
              _buildMemberRow(
                context: context,
                label: member['label']!,
                name: member['name']!,
                nameSize: nameSize,
                labelSize: labelSize,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemberRow({
    required BuildContext context,
    required String label,
    required String name,
    required double nameSize,
    required double labelSize,
  }) {
    return Row(
      children: [
        // Label with icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: labelSize.clamp(14.0, 20.0),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize.clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Connecting line
        Container(
          width: 30,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: nameSize.clamp(16.0, 22.0),
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}