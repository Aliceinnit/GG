import 'package:flutter/material.dart';

class CheckoutWizard extends StatelessWidget {
  final int currentStep;
  final List<String> steps = const [
    'Varukorg',
    'Leverans', 
    'Betalning',
    'Bekräftelse'
  ];

  const CheckoutWizard({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStep(i, context),
            if (i < steps.length - 1) _buildConnector(i, context),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(int index, BuildContext context) {
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;
    final isUpcoming = index > currentStep;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isCompleted) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      borderColor = Theme.of(context).primaryColor;
    } else if (isActive) {
      backgroundColor = Colors.white;
      textColor = Theme.of(context).primaryColor;
      borderColor = Theme.of(context).primaryColor;
    } else {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.grey[600]!;
      borderColor = Colors.grey[300]!;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: textColor,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          steps[index],
          style: TextStyle(
            color: isActive || isCompleted 
                ? Theme.of(context).primaryColor 
                : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int index, BuildContext context) {
    final isCompleted = index < currentStep;
    
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted 
          ? Theme.of(context).primaryColor 
          : Colors.grey[300],
    );
  }
}
