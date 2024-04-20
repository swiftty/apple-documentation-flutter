import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/features/all_technologies/all_technologies_view_model.dart';

class AllTechnologiesPage extends ConsumerStatefulWidget {
  const AllTechnologiesPage({super.key});

  @override
  ConsumerState<AllTechnologiesPage> createState() => _AllTechnologiesPageState();
}

class _AllTechnologiesPageState extends ConsumerState<AllTechnologiesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.send(const OnAppear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allTechnologiesViewModelProvider);

    switch (state) {
      case Pending():
      case Loading():
        return _loading();

      case Loaded():
        return _loaded(state);

      case Failed():
        return _failed(state);
    }
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(Loaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final section in state.technologies.sections)
            if (section is SectionHero)
              referenceView(state.technologies.reference(identifier: section.image))
            else if (section is SectionTechnologies)
              for (final group in section.groups)
                ExpansionTile(
                  title: Text(group.name),
                  children: [
                    for (final technology in group.technologies)
                      ListTile(
                        title: Text(technology.title),
                        subtitle: Text("${technology.content}"),
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Error'),
    );
  }

  AllTechnologiesViewModel get _viewModel => ref.read(allTechnologiesViewModelProvider.notifier);
}

Widget referenceView(Reference? reference) {
  switch (reference) {
    case ReferenceImage():
      return imageView(reference);

    default:
      return const SizedBox();
  }
}

Widget imageView(ReferenceImage image) {
  final url = image.variants.map((variant) => variant.url).firstOrNull;
  if (url == null) {
    return const SizedBox();
  } else {
    return Image.network(url);
  }
}
