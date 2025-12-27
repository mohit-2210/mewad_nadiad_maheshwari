import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';

class CommunityOrganizationsScreen extends StatelessWidget {
  const CommunityOrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Organizations'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.secondary.withOpacity(0.03),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              Gap.s30H(),
              
              // Organizations
              _buildOrganizationCard(
                context: context,
                title: 'माहेश्वरी सेवा समाज केन्द्र',
                subtitle: '(महेश वाटिका)',
                icon: Icons.account_balance,
                color: Colors.deepOrange,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'जगदीशचंद्र लड्ढा'},
                  {'label': 'मंत्री', 'name': 'रामकुमार समदानी'},
                ],
              ),
              
              Gap.s20H(),
              
              _buildOrganizationCard(
                context: context,
                title: 'माहेश्वरी सेवा समिति',
                icon: Icons.groups,
                color: Colors.blue,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'आनंदीलाल हेड़ा'},
                  {'label': 'मंत्री', 'name': 'अशोककुमार मंडोवरा'},
                ],
              ),
              
              Gap.s20H(),
              
              _buildOrganizationCard(
                context: context,
                title: 'माहेश्वरी युवा संगठन',
                icon: Icons.people,
                color: Colors.green,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'उमेशकुमार बांगड'},
                  {'label': 'सह मंत्री', 'name': 'अखिलेश झवर'},
                ],
              ),
              
              Gap.s20H(),
              
              _buildOrganizationCard(
                context: context,
                title: 'माहेश्वरी महिला संगठन',
                icon: Icons.woman,
                color: Colors.pink,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'मंजुदेवी मंडोवरा'},
                  {'label': 'मंत्री', 'name': 'शारदा देवी हेड़ा'},
                ],
              ),
              
              Gap.s20H(),
              
              _buildOrganizationCard(
                context: context,
                title: 'माहेश्वरी फ्रेंड्स क्लब',
                icon: Icons.celebration,
                color: Colors.purple,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'आशादेवी ईनाणी'},
                  {'label': 'मंत्री', 'name': 'N/A'},
                ],
              ),
              
              Gap.s20H(),
              
              _buildOrganizationCard(
                context: context,
                title: 'खेड़ा जिला महा सभा',
                icon: Icons.location_city,
                color: Colors.teal,
                members: [
                  {'label': 'अध्यक्ष', 'name': 'सत्यप्रकाश हेड़ा'},
                  {'label': 'मंत्री', 'name': 'उमेशकुमार बांगड'},
                ],
              ),
              
              Gap.s30H(),
              
              // Footer
              _buildFooter(context),
              
              Gap.s20H(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          Gap.s10H(),
          Text(
            'Our Community Organizations',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Gap.s10H(),
          Text(
            'Leadership and structure of various organizations serving the Maheshwari community',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> members,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Members list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                final isLast = index == members.length - 1;
                
                return Column(
                  children: [
                    _buildMemberRow(
                      context: context,
                      label: member['label']!,
                      name: member['name']!,
                      color: color,
                    ),
                    if (!isLast) ...[
                      Gap.s10H(),
                      Divider(
                        color: Colors.grey[300],
                        height: 1,
                      ),
                      Gap.s10H(),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow({
    required BuildContext context,
    required String label,
    required String name,
    required Color color,
  }) {
    return Row(
      children: [
        // Label badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
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
                color.withOpacity(0.5),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          Gap.s10H(),
          Text(
            'Together We Serve',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Gap.s4H(),
          Text(
            'These organizations work tirelessly to strengthen our community bonds and preserve our cultural heritage.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}