enum ItemType { seperator, data }

class MultiSelectDialogItem {
  int? value;

  String name;
  ItemType type;

  MultiSelectDialogItem({required this.name, required this.type, this.value}) {
    if (type == ItemType.data) {
      assert(value != null, 'Data items must have a value');
    }
  }
}
