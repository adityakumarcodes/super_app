import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum CalendarView { month, year }

class _CalendarPageState extends State<CalendarPage> {
  late int selectedYear;
  CalendarView currentView = CalendarView.month;
  late PageController _pageController;

  final List<int> years = [2024, 2025, 2026, 2027, 2028];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Indian Holidays for 2026
  final Map<String, String> indianHolidays2026 = {
    "2026-01-26": "Republic Day",
    "2026-03-03": "Holi",
    "2026-08-15": "Independence Day",
    "2026-08-16": "Janmashtami",
    "2026-10-02": "Gandhi Jayanti",
    "2026-10-20": "Dussehra",
    "2026-11-08": "Diwali",
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
    _pageController = PageController(initialPage: now.month - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildYearDropdown(colorScheme), _buildViewToggle()],
            ),
          ),
          Expanded(
            child: currentView == CalendarView.month
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: months.length,
                    itemBuilder: (context, index) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildMonthWidget(
                        context,
                        months[index],
                        selectedYear,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: months.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (context, index) =>
                        _buildMonthWidget(context, months[index], selectedYear),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButton<int>(
        value: selectedYear,
        underline: const SizedBox(),
        onChanged: (int? newValue) {
          if (newValue != null) setState(() => selectedYear = newValue);
        },
        items: years
            .map((int v) => DropdownMenuItem(value: v, child: Text("$v")))
            .toList(),
      ),
    );
  }

  Widget _buildViewToggle() {
    return SegmentedButton<CalendarView>(
      segments: const [
        ButtonSegment(
          value: CalendarView.month,
          label: Text('Month'),
          icon: Icon(Icons.calendar_view_day),
        ),
        ButtonSegment(
          value: CalendarView.year,
          label: Text('Year'),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: {currentView},
      onSelectionChanged: (set) => setState(() => currentView = set.first),
    );
  }

  Widget _buildMonthWidget(BuildContext context, String monthName, int year) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "$monthName $year",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildWeekdayLabels(context),
            const SizedBox(height: 12),
            _buildDateGrid(context, monthName, year),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map(
            (day) =>
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
          .toList(),
    );
  }

  Widget _buildDateGrid(BuildContext context, String monthName, int year) {
    final colorScheme = Theme.of(context).colorScheme;
    int monthIndex = months.indexOf(monthName) + 1;
    int daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isToday =
            now.year == year && now.month == monthIndex && now.day == day;
        String dateKey =
            "$year-${monthIndex.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
        String? holidayName = indianHolidays2026[dateKey];

        // Standardized Cell Content
        Widget cell = Container(
          height: 48,
          alignment: Alignment.center,
          decoration: isToday
              ? BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$day",
                style: TextStyle(
                  color: isToday
                      ? colorScheme.onPrimaryContainer
                      : (holidayName != null ? colorScheme.error : null),
                  fontWeight: (holidayName != null || isToday)
                      ? FontWeight.bold
                      : null,
                ),
              ),
              // Placeholder: Always occupies space even if null
              SizedBox(
                height: 6,
                child: holidayName != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );

        if (holidayName != null) {
          return Tooltip(message: holidayName, child: cell);
        }

        return cell;
      },
    );
  }
}
