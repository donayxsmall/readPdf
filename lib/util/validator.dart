class Validator {
  static String? rule(
    String? value, {
    bool required = false,
  }) {
    if (required && value!.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? required(
    dynamic value, {
    String? fieldName,
  }) {
    if (value == null) {
      return "This field is required";
    }

    if (value is String || value == null) {
      if (value.toString() == "null") return "This field is required";
      if (value.isEmpty) return "This field is required";
    }

    if (value is List) {
      if (value.isEmpty) return "This field is required";
    }
    return null;
  }

  static String? requiredPassword(
    String? value,
    String? message,
  ) {
    if (value == null || value == "") {
      return "This field is required";
    }

    if (value.toString() == "null") return "This field is required";
    if (value.isEmpty) return "This field is required";

    if (value is List) {
      if (value.isEmpty) return "This field is required";
    }

    if (message!.isNotEmpty) {
      return "Invalid Password";
    }

    return null;
  }

  static String? email(String? value) {
    if (value!.isEmpty) return "This field is required";

    final bool isValidEmail = RegExp(
            "^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
        .hasMatch(value);

    if (!isValidEmail) {
      return "This field is not in a valid email format";
    }
    return null;
  }

  static String? number(String? value) {
    if (value!.isEmpty) return "This field is required";

    final bool isNumber = RegExp(r"^[0-9]+$").hasMatch(value);
    if (!isNumber) {
      return "This field is not in a valid number format";
    }
    return null;
  }

  static String? atLeastOneitem(List<Map<String, dynamic>> items) {
    var checkedItems = items.where((i) => i["checked"] == true).toList();
    if (checkedItems.isEmpty) {
      return "you must choose at least one item";
    }
    return null;
  }
}
