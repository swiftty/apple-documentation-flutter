import 'package:flutter/material.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';

class TechnologyDetailPage extends StatefulWidget {
  const TechnologyDetailPage({super.key, required this.id});

  final TechnologyId id;

  @override
  State<TechnologyDetailPage> createState() => _TechnologyDetailPageState();
}

class _TechnologyDetailPageState extends State<TechnologyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technology Detail'),
      ),
      body: Text('${widget.id}'),
    );
  }
}
