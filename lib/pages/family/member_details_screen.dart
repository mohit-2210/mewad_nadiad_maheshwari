import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/models/user.dart';

@NowaGenerated()
class MemberDetailsScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MemberDetailsScreen({required this.member, super.key});

  final User member;

  @override
  State<MemberDetailsScreen> createState() {
    return _MemberDetailsScreenState();
  }
}

@NowaGenerated()
class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          Icons.badge,
          'Full Name',
          widget.member.fullName,
        ),
        _buildDetailRow(
          widget.member.isHeadOfFamily ? Icons.home : Icons.people,
          'Relation',
          widget.member.isHeadOfFamily
              ? 'Head of Family'
              : (widget.member.relation ?? 'Family Member'),
        ),
        if (widget.member.dateOfBirth != null)
          _buildDetailRow(
            Icons.cake,
            'Date of Birth',
            '${widget.member.dateOfBirth?.day}/${widget.member.dateOfBirth?.month}/${widget.member.dateOfBirth?.year}',
          ),
        if (widget.member.occupation != null)
          _buildDetailRow(
            Icons.work,
            'Occupation',
            widget.member.occupation!,
          ),
        if(widget.member.occupationAddress != null)
          _buildDetailRow(
            Icons.work,
            'Occupation Address',
            widget.member.occupationAddress!,
          ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.contact_phone,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailRow(Icons.phone, 'Phone Number', widget.member.phoneNumber),
        if (widget.member.email != null)
          _buildDetailRow(Icons.email, 'Email', widget.member.email!),
      ],
    );
  }

  // Widget _buildAdditionalInfoSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.green.withValues(alpha: 0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: const Icon(Icons.info, color: Colors.green, size: 24),
  //           ),
  //           const SizedBox(width: 16),
  //           Text(
  //             'Additional Information',
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.bold,
  //               color: Colors.green,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 20),
  //       if (widget.member.address != null)
  //         _buildDetailRow(Icons.home, 'Address', widget.member.address!),
  //       if (widget.member.society != null)
  //         _buildDetailRow(Icons.apartment, 'Society', widget.member.society!),
  //       if (widget.member.area != null)
  //         _buildDetailRow(Icons.location_on, 'Area', widget.member.area!),
  //       if (widget.member.nativePlace != null)
  //         _buildDetailRow(
  //           Icons.place,
  //           'Native Place',
  //           widget.member.nativePlace!,
  //         ),
  //     ],
  //   );
  // }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, required int delay}) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: Duration(milliseconds: 600 + delay),
      child: AnimatedScale(
        scale: _isVisible ? 1 : 0.95,
        duration: Duration(milliseconds: 600 + delay),
        curve: Curves.easeOutBack,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.member.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'member_${widget.member.id}',
                    child: AnimatedScale(
                      scale: _isVisible ? 1 : 0.8,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: widget.member.profileImage != null
                              ? NetworkImage(widget.member.profileImage!)
                              : null,
                          child: widget.member.profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedCard(
                    child: _buildBasicInfoSection(),
                    delay: 100,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedCard(
                    child: _buildContactInfoSection(),
                    delay: 200,
                  ),
                  // const SizedBox(height: 20),
                  // _buildAnimatedCard(
                  //   child: _buildAdditionalInfoSection(),
                  //   delay: 300,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
