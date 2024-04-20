import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/features/all_technologies/all_technologies_view_model.dart';
import 'package:appledocumentationflutter/features/all_technologies/views/technology_cell.dart';

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
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
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
    return CustomScrollView(
      slivers: [
        for (final section in state.technologies.sections)
          if (section is SectionHero)
            SliverAppBar(
              title: const Text('Technologies'),
              expandedHeight: 160,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: referenceView(
                  state.technologies.reference(identifier: section.image),
                  height: 160,
                ),
                collapseMode: CollapseMode.parallax,
              ),
            )
          else if (section is SectionTechnologies)
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                for (final group in section.groups)
                  for (final technology in group.technologies)
                    TechnologyCell(
                      technology: technology,
                      reference: state.technologies.reference(
                        identifier: technology.destination.identifier,
                      )!,
                      onPressed: () => debugPrint("$technology"),
                    )
              ]),
            )
      ],
    );
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Error'),
    );
  }

  AllTechnologiesViewModel get _viewModel => ref.read(allTechnologiesViewModelProvider.notifier);
}

Widget referenceView(
  Reference? reference, {
  double? height,
}) {
  switch (reference) {
    case ReferenceImage():
      return imageView(
        reference,
        height: height,
      );

    default:
      return SizedBox(height: height);
  }
}

Widget imageView(
  ReferenceImage image, {
  double? height,
}) {
  final url = image.variants.map((variant) => variant.url).firstOrNull;
  if (url == null) {
    return SizedBox(height: height);
  } else {
    return Image.network(
      url,
      fit: BoxFit.cover,
      height: height,
    );
  }
}
