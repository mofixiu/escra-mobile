import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_parser.dart';
import '../../data/models/escrow_event_model.dart';

/// Premium vertical history log feed.
/// Shows milestones connected with a sleek timeline axis.
class TimelineWidget extends StatelessWidget {
  final List<EscrowEventModel> events;

  const TimelineWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No milestones logged for this agreement yet.',
            style: TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final isLatest = index == 0;
        final isOldest = index == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sleek timeline axis line & dot
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLatest ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isLatest ? AppColors.primary : AppColors.silverDark,
                        width: 2.5,
                      ),
                      boxShadow: isLatest
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                  if (!isOldest)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Milestone Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isLatest ? Colors.white : AppColors.silver,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ev.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateParser.formatDateTime(ev.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
