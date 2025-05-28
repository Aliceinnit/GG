import 'package:flutter/material.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  
  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: List.generate(4, (index) { // Only show 4 steps (exclude confirmation)
              bool isActive = index == currentStep;
              bool isCompleted = index < currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted ? Colors.deepPurple : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              bool isActive = index == currentStep;
              bool isCompleted = index < currentStep;
              
              return Expanded(
                child: Text(
                  stepTitles[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive || isCompleted ? Colors.deepPurple : Colors.grey[500],
                  ),
                  textAlign: index == 0 ? TextAlign.start : 
                           index == 3 ? TextAlign.end : TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
