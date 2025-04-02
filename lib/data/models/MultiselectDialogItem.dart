class MultiSelectDialogItem {
  int value;

  String name;
  ItemType type;

  MultiSelectDialogItem({
    required this.name,
    required this.type,
    required this.value,
  });
}

enum ItemType { seperator, data }
