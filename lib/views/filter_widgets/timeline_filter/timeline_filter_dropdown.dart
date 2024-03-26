import "package:flutter/material.dart";
import "package:proxima/views/filter_widgets/timeline_filter/timeline_filters.dart";

class TimeLineFiltersDropDown extends StatelessWidget {
  const TimeLineFiltersDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      dropdownMenuEntries: createFilterItems(context),
      initialSelection: TimeLineFilters.f1,
      onSelected: (value) {
        //TODO: Implement the logic to change the filter
      },
    );
  }
}
