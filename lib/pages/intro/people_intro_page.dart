import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';

class PeopleIntroPage extends StatelessWidget {
  final List<Map<String, String>> people;

  const PeopleIntroPage({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Meet Our Community",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap.s20H(),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // important
            shrinkWrap: true, // important
            padding: EdgeInsets.zero,
            itemCount: people.length,

            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.80,
            ),

            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      people[index]["image"]!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    people[index]["name"]!,
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
        ],
      ),
    );
  }
}
