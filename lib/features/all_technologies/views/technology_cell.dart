import 'package:flutter/material.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';

class TechnologyCell extends StatefulWidget {
  const TechnologyCell({
    super.key,
    required this.technology,
    required this.reference,
    this.onPressed,
  });

  final Technology technology;
  final Reference reference;
  final Function()? onPressed;

  @override
  State<TechnologyCell> createState() => _TechnologyCellState();
}

class _TechnologyCellState extends State<TechnologyCell> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onPressed,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);

    final animationColor = ColorTween(
      begin: theme.colorScheme.secondary,
      end: theme.colorScheme.primary,
    ).animate(_controller);

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.02).animate(_controller),
      child: AnimatedBuilder(
        animation: animationColor,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: animationColor.value ?? theme.colorScheme.secondary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          );
        },
        child: _content(theme),
      ),
    );
  }

  Widget _content(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.technology.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          children: [
                            if (widget.reference case ReferenceTopic(:final abstract)
                                when abstract.isNotEmpty)
                              for (final abstract in abstract)
                                TextSpan(
                                  text: abstract.text,
                                )
                            else if (widget.technology.content.isNotEmpty)
                              for (final abstract in widget.technology.content)
                                TextSpan(
                                  text: abstract.text,
                                )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final tag in widget.technology.tags)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
