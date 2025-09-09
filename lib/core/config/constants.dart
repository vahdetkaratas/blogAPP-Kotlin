import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ThinkEasy Mini';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://frontend-test-be.stage.thinkeasy.cz';
  
  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const int maxRetryAttempts = 3;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 100;
  static const int maxContentLength = 1000;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Custom Colors for Login Design
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color primaryRed = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF181111);
  
  // Custom Colors for Posts Design
  static const Color primaryGreen = Color(0xFF06D6A0);
  static const Color lightGray = Color(0xFFF9FAFB);
}

