enum ItemType { seperator, data }

class MultiSelectDialogItem {
  String sensorName;

  String? attribute;
  ItemType type;

  MultiSelectDialogItem({
    this.attribute,
    required this.type,
    required this.sensorName,
  }) {
    if (type == ItemType.data) {
      assert(attribute != null, 'Data items must have a value');
    }
  }
}
