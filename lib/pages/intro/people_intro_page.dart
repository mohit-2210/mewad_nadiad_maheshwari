import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';

/// Simple grid page for up to 12 people.
/// Paging (multiple screens + dots) is handled by the parent (IntroScreen or PeopleIntroScreen).
class PeopleIntroPage extends StatelessWidget {
  final List<Map<String, String>> people;

  const PeopleIntroPage({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Gap.s20H(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.80,
            ),
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      person['image']!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    person['name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
