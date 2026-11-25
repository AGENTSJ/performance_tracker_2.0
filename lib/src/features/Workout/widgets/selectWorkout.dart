import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/pages/workoutDetails.page.dart';
import 'package:performance_tracker/src/features/Workout/services/workout.service.dart';
import 'package:performance_tracker/src/features/Workout/widgets/routineSelection.component.dart';

/// Opens the workout picker as a bottom sheet. Picked workouts are added to
/// [selectedWorkouts] in place; read it once the returned future completes.
/// With [includeRoutines], a second tab lets the user pull in a whole routine.
Future<void> showWorkoutPickerSheet(
  BuildContext context, {
  required List<Workout> selectedWorkouts,
  bool includeRoutines = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: SURFACE2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        // Lift the content above the keyboard while searching.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _WorkoutPickerSheet(
          selectedWorkouts: selectedWorkouts,
          includeRoutines: includeRoutines,
        ),
      ),
    ),
  );
}

class _WorkoutPickerSheet extends StatefulWidget {
  final List<Workout> selectedWorkouts;
  final bool includeRoutines;
  const _WorkoutPickerSheet({
    required this.selectedWorkouts,
    required this.includeRoutines,
  });

  @override
  State<_WorkoutPickerSheet> createState() => _WorkoutPickerSheetState();
}

class _WorkoutPickerSheetState extends State<_WorkoutPickerSheet> {
  final _pageController = PageController();
  int _tab = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int tab) {
    setState(() => _tab = tab);
    _pageController.animateToPage(
      tab,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: BORDER_PRIMARY,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Text(
            "Add workouts",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: TEXT_PRIMARY,
            ),
          ),
        ),
        if (widget.includeRoutines)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: _tabs(),
          ),
        Expanded(
          child: widget.includeRoutines
              ? PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _tab = page),
                  children: [
                    SelectWorkout(selectedWorkouts: widget.selectedWorkouts),
                    RoutineSelection(selectedWorkouts: widget.selectedWorkouts),
                  ],
                )
              : SelectWorkout(selectedWorkouts: widget.selectedWorkouts),
        ),
      ],
    );
  }

  Widget _tabs() {
    Widget tab(int index, String label, IconData icon) {
      final selected = _tab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => _goToTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 9.h),
            decoration: BoxDecoration(
              color: selected ? SURFACE2 : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? BORDER_PRIMARY : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 12.sp,
                  color: selected ? PRIMARY : TEXT_SECONDARY,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? TEXT_PRIMARY : TEXT_SECONDARY,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: SURFACE,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          tab(0, "Workouts", FontAwesomeIcons.dumbbell),
          SizedBox(width: 4.w),
          tab(1, "Routines", FontAwesomeIcons.layerGroup),
        ],
      ),
    );
  }
}

/// Searchable list of workouts not yet in [selectedWorkouts]. Tapping a
/// workout adds it (tap again to undo); "Create workout" opens the workout
/// editor and adds the new workout once the user comes back.
class SelectWorkout extends StatefulWidget {
  final List<Workout> selectedWorkouts;
  const SelectWorkout({super.key, required this.selectedWorkouts});

  @override
  SelectWorkoutState createState() => SelectWorkoutState();
}

class SelectWorkoutState extends State<SelectWorkout>
    with AutomaticKeepAliveClientMixin {
  final workoutService = locator<WorkoutService>();
  final searchController = TextEditingController();

  /// Workouts already selected before the sheet opened; never listed.
  late final Set<dynamic> _alreadySelectedKeys;

  /// Workouts added while the sheet is open; listed with a check mark.
  final Set<dynamic> _addedKeys = {};

  List<Workout> workouts = [];

  @override
  bool get wantKeepAlive => true;

  String get _query => searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _alreadySelectedKeys = widget.selectedWorkouts.map((w) => w.key).toSet();
    _loadWorkouts();
    searchController.addListener(_loadWorkouts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadWorkouts() {
    final source = _query.isEmpty
        ? workoutService.getAllWorkouts()
        : workoutService.searchWorkoutByName(_query);
    workouts = source
        .where((w) => !_alreadySelectedKeys.contains(w.key))
        .toList();
    refreshState();
  }

  bool _isAdded(Workout work) => _addedKeys.contains(work.key);

  /// True when a workout with exactly the searched name already exists.
  bool get _queryMatchesExisting {
    final query = _query.toLowerCase();
    return workoutService.getAllWorkouts().any(
      (w) => w.name.toLowerCase() == query,
    );
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  handleSelectWorkout(Workout work) {
    if (_isAdded(work)) {
      widget.selectedWorkouts.removeWhere((w) => w.key == work.key);
      _addedKeys.remove(work.key);
    } else {
      widget.selectedWorkouts.add(work);
      _addedKeys.add(work.key);
    }
    refreshState();
  }

  handleCreateWorkout() async {
    final name = _query.isNotEmpty && !_queryMatchesExisting
        ? _query
        : "New One";
    final keysBefore = workoutService
        .getAllWorkouts()
        .map((w) => w.key)
        .toSet();
    FocusScope.of(context).unfocus();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsPage(
          workout: Workout(
            name: name,
            sets: [],
            enabled: true,
            desc: '',
            volumes: [],
          ),
          isCreateMode: true,
        ),
      ),
    );
    if (!mounted) return;
    // Whatever was created (and not deleted again) gets selected.
    final created = workoutService.getAllWorkouts().where(
      (w) => !keysBefore.contains(w.key),
    );
    for (final work in created) {
      widget.selectedWorkouts.add(work);
      _addedKeys.add(work.key);
    }
    searchController.clear(); // also reloads the list
    _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
          child: _searchField(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _createTile(),
        ),
        SizedBox(height: 4.h),
        Expanded(
          child: workouts.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  itemCount: workouts.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, i) {
                    final work = workouts[i];
                    return PickerTile(
                      icon: FontAwesomeIcons.dumbbell,
                      title: work.name,
                      subtitle: _workoutSubtitle(work),
                      selected: _isAdded(work),
                      onTap: () => handleSelectWorkout(work),
                    );
                  },
                ),
        ),
        _doneBar(),
      ],
    );
  }

  String _workoutSubtitle(Workout work) {
    final sets = work.sets.length;
    final setsText = sets == 0
        ? "No sets yet"
        : "$sets set${sets == 1 ? '' : 's'}";
    if (work.volumes.isEmpty) return setsText;
    final muscles = work.volumes.map((v) => v.muscleName).take(3).join(", ");
    return "$setsText · $muscles";
  }

  Widget _searchField() {
    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 14.sp, color: TEXT_PRIMARY),
      decoration: InputDecoration(
        hintText: 'Search workouts',
        hintStyle: TextStyle(color: TEXT_SECONDARY, fontSize: 14.sp),
        filled: true,
        fillColor: SURFACE,
        isDense: true,
        prefixIcon: Icon(Icons.search, color: TEXT_SECONDARY, size: 20.sp),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: TEXT_SECONDARY, size: 18.sp),
                onPressed: () => searchController.clear(),
              ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BORDER_PRIMARY),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BORDER_PRIMARY),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: PRIMARY),
        ),
      ),
    );
  }

  Widget _createTile() {
    final useQuery = _query.isNotEmpty && !_queryMatchesExisting;
    return Material(
      color: PRIMARY.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: handleCreateWorkout,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: PRIMARY,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      useQuery ? 'Create "$_query"' : "Create workout",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: PRIMARY,
                      ),
                    ),
                    Text(
                      "Set it up, then it's added here",
                      style: TextStyle(fontSize: 11.sp, color: TEXT_SECONDARY),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: PRIMARY, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(width: 90.w, height: 90.h, child: empty),
            SizedBox(height: 10.h),
            Text(
              _query.isEmpty
                  ? "No workouts left to add"
                  : 'No workouts match "$_query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: TEXT_PRIMARY,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Create one above",
              style: TextStyle(fontSize: 12.sp, color: TEXT_SECONDARY),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doneBar() {
    final count = _addedKeys.length;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: BORDER_SECONDARY)),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMARY,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          count == 0
              ? "Done"
              : "Add $count workout${count == 1 ? '' : 's'}",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
        ),
      ),
    );
  }
}

/// A row in the picker: tinted icon, title, subtitle, and an add/check mark.
class PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const PickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.trailingIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PRIMARY.withValues(alpha: 0.06) : SURFACE2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: selected ? PRIMARY : BORDER_PRIMARY),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: SURFACE,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 15.sp, color: TEXT_SECONDARY),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: TEXT_PRIMARY,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: TEXT_SECONDARY,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  selected ? Icons.check_circle : trailingIcon,
                  key: ValueKey(selected),
                  color: selected ? PRIMARY : TEXT_SECONDARY,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
