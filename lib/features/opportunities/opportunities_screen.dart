import 'package:flutter/material.dart';

import '../../domain/opportunity.dart';
import 'opportunity_editor_dialog.dart';
import 'opportunity_view_model.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key, required this.viewModel});

  final OpportunityViewModel viewModel;
  static const _filters = [
    'All',
    'Saved',
    'Applied',
    'Interviewing',
    'Archived'
  ];

  Future<void> _openEditor(BuildContext context, [Opportunity? initial]) async {
    final opportunity = await showDialog<Opportunity>(
      context: context,
      builder: (_) => OpportunityEditorDialog(initial: initial),
    );
    if (opportunity == null) return;
    final saved = initial == null
        ? await viewModel.add(opportunity)
        : await viewModel.update(opportunity);
    if (context.mounted && !saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The change could not be saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.track_changes_rounded, size: 22),
            SizedBox(width: 10),
            Text('Opportunity Tracker'),
          ],
        ),
        backgroundColor: const Color(0xFFF5F8F7),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'About this app',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Opportunity Tracker',
              applicationVersion: '1.0.0',
              children: const [
                Text(
                    'Records stay on this device; this demo does not encrypt them.'),
              ],
            ),
            icon: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 1080 ? 1080.0 : constraints.maxWidth;
            final innerWidth = maxWidth > 40 ? maxWidth - 40 : maxWidth;
            final wide = innerWidth >= 740;
            final cardWidth = wide ? (innerWidth - 16) / 2 : innerWidth;
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: AnimatedBuilder(
                  animation: viewModel,
                  builder: (context, _) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(onAdd: () => _openEditor(context)),
                        const SizedBox(height: 16),
                        _OverviewMetrics(viewModel: viewModel),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: viewModel.setQuery,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search opportunities',
                            labelText: 'Search',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _filters
                              .map(
                                (filter) => ChoiceChip(
                                  label: _FilterLabel(
                                    title: filter,
                                    count: viewModel.countForFilter(filter),
                                  ),
                                  selected: viewModel.activeFilter == filter,
                                  onSelected: (_) =>
                                      viewModel.setFilter(filter),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.errorMessage != null)
                          _ErrorPanel(
                            message: viewModel.errorMessage!,
                            onRetry: viewModel.load,
                          ),
                        if (viewModel.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (viewModel.visibleOpportunities.isEmpty)
                          _EmptyState(
                            hasAny: viewModel.activeFilter != 'All' ||
                                viewModel.query.trim().isNotEmpty,
                            onAdd: () => _openEditor(context),
                          )
                        else
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: viewModel.visibleOpportunities
                                .map(
                                  (opportunity) => SizedBox(
                                    width: cardWidth,
                                    child: OpportunityCard(
                                      opportunity: opportunity,
                                      onEdit: () =>
                                          _openEditor(context, opportunity),
                                      onStatus: (status) => viewModel.setStatus(
                                          opportunity, status),
                                      onDelete: () async {
                                        final confirmed =
                                            await _confirmDelete(context);
                                        if (!confirmed) return;
                                        final saved = await viewModel
                                            .remove(opportunity.id);
                                        if (context.mounted && !saved) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'The record could not be deleted.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 24),
                        const Text(
                          'Records stay on this device, but local storage is not encrypted by this demo.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete opportunity?'),
        content: const Text('This record will be removed from local storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR NEXT STEP',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your next opportunity in view.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save a listing and track it at your own pace.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        );
        final addButton = FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add opportunity'),
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFF0E534C),
            backgroundColor: Colors.white,
            minimumSize: const Size(156, 48),
          ),
        );

        return Container(
          padding: EdgeInsets.all(compact ? 20 : 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF176B63), Color(0xFF0E4D49)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A176B63),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 18),
                    Align(alignment: Alignment.centerRight, child: addButton),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 24),
                    addButton,
                  ],
                ),
        );
      },
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.viewModel});

  final OpportunityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;
        final metrics = [
          _MetricData(
              'Opportunities', viewModel.totalCount, Icons.work_outline),
          _MetricData(
            'Saved',
            viewModel.countForStatus(OpportunityStatus.saved),
            Icons.bookmark_border_rounded,
          ),
          _MetricData(
            'Applied',
            viewModel.countForStatus(OpportunityStatus.applied),
            Icons.send_outlined,
          ),
          _MetricData(
            'Interviewing',
            viewModel.countForStatus(OpportunityStatus.interviewing),
            Icons.forum_outlined,
          ),
        ];
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map((metric) =>
                  SizedBox(width: width, child: _MetricCard(data: metric)))
              .toList(),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 19, color: colors.primary),
                const Spacer(),
                Text(
                  '${data.value}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(data.label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Text('$title  $count');
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onEdit,
    required this.onStatus,
    required this.onDelete,
  });

  final Opportunity opportunity;
  final VoidCallback onEdit;
  final ValueChanged<OpportunityStatus> onStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final addedDate = _formatDate(opportunity.createdAt);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    opportunity.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                PopupMenuButton<OpportunityStatus>(
                  tooltip: 'Change status',
                  onSelected: onStatus,
                  itemBuilder: (context) => OpportunityStatus.values
                      .map(
                        (status) => PopupMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(opportunity.platform),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusBadge(status: opportunity.status),
                if (opportunity.budget.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.payments_outlined, size: 18),
                    label: Text(opportunity.budget),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (opportunity.url.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText(
                opportunity.url,
                style: TextStyle(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
            if (opportunity.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                opportunity.notes,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Added $addedDate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OpportunityStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(status.label),
      backgroundColor: colorScheme.secondaryContainer,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasAny, required this.onAdd});

  final bool hasAny;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              hasAny ? 'No matching opportunities' : 'Your list is ready.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasAny
                  ? 'Try another search or status filter.'
                  : 'Add a role when you find one worth tracking.',
              textAlign: TextAlign.center,
            ),
            if (!hasAny) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add your first opportunity'),
                style:
                    OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
