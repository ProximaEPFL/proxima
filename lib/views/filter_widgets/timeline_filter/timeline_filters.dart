//create a enum with all the routes for the bottom bar with icons and names

import "package:flutter/material.dart";

/*
  This enum is used to create the timeline filters.
  It contains the name and icon of the filters.
*/
enum TimeLineFilters {
  f1("Filter 1", Icon(Icons.abc)),
  f2("Filter 2", Icon(Icons.filter_none)),
  f3("Filter 3", Icon(Icons.accessibility_new_outlined)),
  f4("Filter 4", Icon(Icons.filter_6_outlined)),
  f5("Filter 5", Icon(Icons.access_alarm));

  final String name;
  final Widget icon;

  const TimeLineFilters(this.name, this.icon);
}
