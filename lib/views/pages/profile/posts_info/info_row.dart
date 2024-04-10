import "package:flutter/material.dart";

/// This widget defines the style of the rows in the profile page,
/// such as the badges row
class InfoRow extends StatelessWidget {
  static const infoRowKey = Key("infoRow");
  const InfoRow({
    super.key,
    required this.itemList,
    required this.title,
  });

  final List<Widget> itemList;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: infoRowKey,
      height: 100,
      width: 380,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              scrollDirection: Axis.horizontal,
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                return itemList[index];
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
            ),
          ),
        ],
      ),
    );
  }
}
