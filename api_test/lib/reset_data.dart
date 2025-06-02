import 'package:api_test/model/imat_data_handler.dart';
import 'package:flutter/material.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Starting user data reset process...');

  final dataHandler = ImatDataHandler();
  

  await Future.delayed(const Duration(seconds: 2));
  
 
  await dataHandler.reset();
  
  print('User data reset completed successfully!');
  print('You can now exit this script with Ctrl+C');
}