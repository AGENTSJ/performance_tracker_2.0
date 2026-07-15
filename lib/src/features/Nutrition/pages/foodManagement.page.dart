import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/foods.service.dart';
import 'package:performance_tracker/constants.ui.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});

  @override
  State<FoodManagementPage> createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  final foodService = locator<FoodService>();
  final searchController = TextEditingController();
  List<Food> _allFoods = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  void _loadFoods() {
    _allFoods = foodService.getAllFoods();
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Food> get _visibleFoods {
    if (_query.isEmpty) return _allFoods;
    final q = _query.toLowerCase();
    return _allFoods
        .where((food) => food.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirmDelete(Food food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CONT_BACKGROUND,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Text('Delete food?', style: TextStyle(color: TEXT_PRIMARY)),
        content: Text(
          'Remove "${food.name}" from your food library. '
          'Days where you already tracked it stay unchanged.',
          style: TextStyle(color: TEXT_SECONDARY, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ACCENT,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await foodService.removeFood(food);
    Fluttertoast.showToast(msg: '"${food.name}" removed');
    _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    final foods = _visibleFoods;
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: const Text('Food Management'),
        backgroundColor: BACKGROUND,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search foods',
                prefixIcon: Icon(Icons.search, color: TEXT_SECONDARY),
                filled: true,
                fillColor: CONT_BACKGROUND,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: BORDER_PRIMARY),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: BORDER_PRIMARY),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: PRIMARY),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${foods.length} ${foods.length == 1 ? 'food' : 'foods'}',
                style: TextStyle(color: TEXT_SECONDARY, fontSize: 12.sp),
              ),
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: foods.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) => _foodTile(foods[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodTile(Food food) {
    return Container(
      decoration: BoxDecoration(
        color: CONT_BACKGROUND,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: BORDER_PRIMARY),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      color: TEXT_PRIMARY,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${food.macros.calories.round()} kcal · '
                    'P ${food.macros.protein.round()}g · '
                    'C ${food.macros.carbohydrate.round()}g · '
                    'F ${food.macros.fat.round()}g  (per 100g)',
                    style: TextStyle(color: TEXT_SECONDARY, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(food),
              icon: Icon(Icons.delete_outline, color: ACCENT, size: 20.sp),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_meals, color: TEXT_TERTIARY, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            _query.isEmpty
                ? 'No foods in your library yet.'
                : 'No foods match "$_query".',
            style: TextStyle(color: TEXT_SECONDARY, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
