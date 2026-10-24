part of '../uibuilder.dart';

class ChecklistWidget extends StatefulWidget {
  final List<dynamic> items;

  const ChecklistWidget({super.key, required this.items});

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items
          .map((item) {
            final itemData = _asMap(item);
            final meta = _asMap(itemData['meta']);
            final children = _asList(itemData['items']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: meta['checked'] == true,
                    onChanged: (value) {
                      setState(() {
                        meta['checked'] = value ?? false;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: SelectableText(
                      _plainText(itemData['content'] ?? item),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: ChecklistWidget(items: children),
                    ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class DelimiterWidget extends StatelessWidget {
  const DelimiterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.asterisk, size: 15),
          Icon(LucideIcons.asterisk, size: 15),
          Icon(LucideIcons.asterisk, size: 15),
        ],
      ),
    );
  }
}

class HeadingWidget extends StatelessWidget {
  static final Map<int, TextStyle Function(TextTheme)> _headingStyles = {
    1: (theme) => theme.headlineLarge!,
    2: (theme) => theme.headlineMedium!,
    3: (theme) => theme.headlineSmall!,
    4: (theme) => theme.titleLarge!,
    5: (theme) => theme.titleMedium!,
    6: (theme) => theme.titleSmall!,
  };

  final String text;
  final int level;

  const HeadingWidget({super.key, required this.text, this.level = 1});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = _headingStyles[level.clamp(1, 6)]!(textTheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(text, style: headingStyle),
    );
  }
}

class RecursiveListWidget extends StatelessWidget {
  final List<dynamic> items;
  final bool ordered;
  final int indentLevel;

  const RecursiveListWidget({
    super.key,
    required this.items,
    this.ordered = false,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final itemData = _asMap(item);
        final content = itemData.isEmpty ? item : itemData['content'];
        final children = _asList(itemData['items']);

        return Padding(
          padding: EdgeInsets.only(left: 16.0 * indentLevel, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ordered ? '${index + 1}.' : '•',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      _plainText(content),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (children.isNotEmpty)
                RecursiveListWidget(
                  items: children,
                  ordered: ordered,
                  indentLevel: indentLevel + 1,
                ),
            ],
          ),
        );
      }),
    );
  }
}

class CalloutWidget extends StatelessWidget {
  final String text;

  const CalloutWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
