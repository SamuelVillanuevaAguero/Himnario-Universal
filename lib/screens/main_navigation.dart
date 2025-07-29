import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import 'categories_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    HimnarioHomePage(),
    FavoritesPage(),
    CategoriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Detectar si está en modo oscuro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        // Aplicar colores según el tema
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundPrimary,
        selectedItemColor: isDarkMode ? AppColors.primaryLight : AppColors.primary,
        unselectedItemColor: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDarkMode ? AppColors.textWhiteSecondary : AppColors.textSecondary,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Himnos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
        ],
      ),
    );
  }
}