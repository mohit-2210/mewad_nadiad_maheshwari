import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';

class PeopleIntroPage extends StatelessWidget {
  final List<Map<String, String>> people;

  const PeopleIntroPage({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          /// --- Responsive Grid ---
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: people.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150, // controls number of columns
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.80, // avatar + name
              ),
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      // borderRadius: BorderRadius.circular(100), // circular
                      child: Image.asset(
                        people[index]["image"]!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Gap.s8H(),
                    Text(
                      people[index]["name"]!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
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
      ),
    );
  }
}
