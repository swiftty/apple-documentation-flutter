import 'package:flutter/material.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/features/all_technologies/all_technologies_view_model.dart';
import 'package:appledocumentationflutter/features/all_technologies/views/technology_cell.dart';

class AllTechnologiesPage extends ConsumerStatefulWidget {
  const AllTechnologiesPage({super.key});

  @override
  ConsumerState<AllTechnologiesPage> createState() => _AllTechnologiesPageState();
}

class _AllTechnologiesPageState extends ConsumerState<AllTechnologiesPage> {
  AllTechnologiesViewModel get _viewModel => ref.read(allTechnologiesViewModelProvider.notifier);
  final queryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.send(const OnAppear());
    });
  }

  @override
  void dispose() {
    super.dispose();
    queryController.dispose();
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

  Widget _loaded(Loaded loaded) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        if (loaded.heroSection case final hero?)
          if (hero.image case final heroImage?)
            SliverAppBar(
              title: const Text(
                'Technologies',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              expandedHeight: 160,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _appbar(
                  loaded,
                  background: loaded.technologies.reference(heroImage),
                  height: 160,
                ),
                collapseMode: CollapseMode.parallax,
                stretchModes: const [
                  StretchMode.blurBackground,
                  StretchMode.zoomBackground,
                ],
              ),
            ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            if (loaded.filteredTechnologies case final technologies)
              if (technologies.isNotEmpty) ...[
                for (final tech in technologies)
                  if (tech.destination.identifier case final identifier?)
                    if (loaded.technologies.reference(identifier) case final ref?)
                      if (ref is ReferenceTopic)
                        TechnologyCell(
                          technology: tech,
                          reference: ref,
                          onPressed: () =>
                              context.push('/detail?id=${Uri.encodeComponent(ref.url.value)}'),
                        ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      color: theme.colorScheme.secondary,
                      radius: const Radius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'No results found Try changing or removing text and tags.',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
          ]),
        ),
      ],
    );
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Error'),
    );
  }

  // MARK: components
  Widget _appbar(
    Loaded loaded, {
    Reference? background,
    double? height,
  }) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          _imageView(background, height: height),
          Column(
            children: [
              const Expanded(child: SizedBox()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: queryController,
                  decoration: const InputDecoration(
                    hintText: 'Filter on this page',
                  ),
                  onChanged: (value) => _viewModel.send(FilterQuery(value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageView(
    Reference? reference, {
    double? height,
  }) {
    switch (reference) {
      case ReferenceImage():
        final url = reference.variants.map((variant) => variant.url).firstOrNull;
        if (url == null) {
          return const SizedBox();
        } else {
          return Image.network(
            url,
            fit: BoxFit.cover,
            height: height,
          );
        }

      default:
        return const SizedBox();
    }
  }
}
