import 'package:flutter/material.dart';
import 'package:flutter_trigger_input_example/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<HomeItem> items = [
    HomeItem(
        title: 'Flutter Quill',
        subtitle: 'Use the flutter_quill library.',
        route: AppRoutes.flutterQuill),
    HomeItem(
        title: 'Trigger Input',
        subtitle: 'Use the flutter_trigger_input library.',
        route: AppRoutes.triggerInput),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Trigger Input Example')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  items[index].title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  items[index].subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              onTap: () => Navigator.pushNamed(context, items[index].route),
            ),
          );
        },
      ),
    );
  }
}

class HomeItem {
  final String title;
  final String subtitle;
  final String route;

  HomeItem({required this.title, required this.subtitle, required this.route});

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      title: json['title'],
      subtitle: json['subtitle'],
      route: json['route'],
    );
  }
}
