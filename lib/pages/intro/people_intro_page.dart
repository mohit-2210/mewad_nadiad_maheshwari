import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';

class PeopleIntroPage extends StatelessWidget {
  final List<Map<String, String>> people;

  const PeopleIntroPage({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        int itemCount = people.length;

        // --------- AUTO-CALCULATE GRID LAYOUT ---------

        // Try columns from 3 to 6 and find best fit
        int optimalColumns = 4;
        double bestItemSize = 0;

        for (int columns = 3; columns <= 7; columns++) {
          int rows = (itemCount / columns).ceil();

          double totalSpacingVertical = (rows - 1) * 16;
          double availableHeight = screenHeight - 80 - totalSpacingVertical; // title space

          double itemHeight = availableHeight / rows;

          double itemWidth = screenWidth / columns;

          double itemSize = itemHeight < itemWidth ? itemHeight : itemWidth;

          if (itemSize > bestItemSize) {
            bestItemSize = itemSize;
            optimalColumns = columns;
          }
        }

        int columns = optimalColumns;
        int rows = (itemCount / columns).ceil();
        double itemSize = bestItemSize;

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

              // --------- FIXED GRID WITH NO SCROLL ---------
              SizedBox(
                height: rows * itemSize + (rows - 1) * 16,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // No Scroll
                  itemCount: itemCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8, // image + name
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            people[index]["image"]!,
                            height: itemSize * 0.75,
                            width: itemSize * 0.75,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Gap.s4H(),
                        Text(
                          people[index]["name"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
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
      },
    );
  }
}
