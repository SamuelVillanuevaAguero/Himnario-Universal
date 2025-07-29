import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import '../constants/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himnario Universal',
      
      // Tema claro
      theme: ThemeData(
        primarySwatch: AppColors.createMaterialColor(AppColors.primary),
        colorScheme: AppColors.lightColorScheme,
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.backgroundSecondary,
          elevation: 2,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          titleLarge: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: IconThemeData(
          color: AppColors.textSecondary,
        ),
        dividerColor: AppColors.divider,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // Tema oscuro
      darkTheme: ThemeData(
        primarySwatch: AppColors.createMaterialColor(AppColors.primaryLight),
        colorScheme: AppColors.darkColorScheme,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundCard,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.backgroundCard,
          elevation: 2,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textWhite),
          bodyMedium: TextStyle(color: AppColors.textWhiteSecondary),
          titleLarge: TextStyle(color: AppColors.textWhite),
        ),
        iconTheme: IconThemeData(
          color: AppColors.textWhiteSecondary,
        ),
        dividerColor: AppColors.borderDark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // Esto hace que el tema se seleccione automáticamente según la configuración del sistema
      themeMode: ThemeMode.system,
      
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}