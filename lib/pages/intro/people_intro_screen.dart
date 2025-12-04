import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/AppImages.dart';
import 'package:mmsn/app/globals/app_localizations.dart';
import 'package:mmsn/pages/intro/people_intro_page.dart';

class PeopleIntroScreen extends StatefulWidget {
  const PeopleIntroScreen({super.key});

  @override
  State<PeopleIntroScreen> createState() => _PeopleIntroScreenState();
}

class _PeopleIntroScreenState extends State<PeopleIntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const int _pageSize = 12;

  List<List<Map<String, String>>> get _chunks {
    final people = AppImages.peopleList;
    final List<List<Map<String, String>>> pages = [];
    for (int i = 0; i < people.length; i += _pageSize) {
      final end = (i + _pageSize > people.length) ? people.length : i + _pageSize;
      pages.add(people.sublist(i, end));
    }
    if (pages.isEmpty) {
      pages.add([]);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _chunks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.text(context, 'introMeetCommunity'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) =>
                  PeopleIntroPage(people: pages[index]),
            ),
          ),
          const SizedBox(height: 12),
          if (pages.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 22 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}


