//create a enum with all the filter for the filter bar.

/*
  This enum is used to create the timeline filters.
  It contains the name of the filters.
*/
enum TimeLineFilters {
  nearest("Nearest"),
  best("Best"),
  newFilter("New"),
  top("Top"),
  hot("Hot");

  final String name;

  const TimeLineFilters(this.name);
}
