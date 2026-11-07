import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class StatusTimeline extends StatelessWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final current = statuses.indexOf(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < statuses.length; i++)
          Expanded(
            child: _TimelineStep(
              label: statuses[i],
              index: i,
              current: current,
              total: statuses.length,
            ),
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final int total;

  const _TimelineStep({
    required this.label,
    required this.index,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    const idleColor = Color(0xFFD9D4EC);

    final reached = index <= current;
    final isCurrent = index == current;
    final isLast = index == total - 1;

    return Column(
      children: [
        Row(
          children: [
            // line on the left
            Expanded(
              child: Container(
                height: 3,
                color: index == 0
                    ? Colors.transparent
                    : (reached ? activeColor : idleColor),
              ),
            ),
            // the circle
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? activeColor : Colors.white,
                border: Border.all(
                  color: reached ? activeColor : idleColor,
                  width: 2,
                ),
              ),
              child: reached
                  ? Icon(
                      isCurrent && !isLast ? Icons.circle : Icons.check,
                      size: isCurrent && !isLast ? 8 : 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            // line on the right
            Expanded(
              child: Container(
                height: 3,
                color: isLast
                    ? Colors.transparent
                    : (index < current ? activeColor : idleColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: reached ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
