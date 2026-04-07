import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class RideStatusTimeline extends StatelessWidget {
  final String status;

  const RideStatusTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statuses = [
      {'key': 'requested', 'label': 'Requested', 'icon': Icons.search},
      {'key': 'accepted', 'label': 'Driver Assigned', 'icon': Icons.person},
      {'key': 'arrived', 'label': 'Driver Arrived', 'icon': Icons.location_on},
      {'key': 'started', 'label': 'Trip Started', 'icon': Icons.directions_car},
      {'key': 'completed', 'label': 'Trip Completed', 'icon': Icons.flag},
    ];

    int currentIndex = -1;
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i]['key'] == status) {
        currentIndex = i;
        break;
      }
    }

    return Column(
      children: [
        Row(
          children: List.generate(statuses.length, (index) {
            final isCompleted = index <= currentIndex;
            final isLast = index == statuses.length - 1;

            return Expanded(
              child: Row(
                children: [
                  _StatusCircle(
                    icon: statuses[index]['icon'] as IconData,
                    isCompleted: isCompleted,
                    isCurrent: index == currentIndex,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted && index < currentIndex
                            ? AppColors.primary
                            : AppColors.greyLight,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(statuses.length, (index) {
            return Expanded(
              child: Text(
                statuses[index]['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: index <= currentIndex
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: index == currentIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;

  const _StatusCircle({
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.primary : Colors.white,
        border: Border.all(
          color: isCompleted ? AppColors.primary : AppColors.greyLight,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: isCompleted ? Colors.white : AppColors.grey,
      ),
    );
  }
}