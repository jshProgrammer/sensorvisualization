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

  @override
  bool operator ==(Object other) {
    return other is MultiSelectDialogItem &&
        other.sensorName == sensorName &&
        other.attribute == attribute &&
        other.type == type;
  }

  @override
  int get hashCode =>
      sensorName.hashCode ^ (attribute?.hashCode ?? 0) ^ type.hashCode;
}
