class ListFilterAddDetails {
  final String label;
  final String fieldName;
  final String required;
  final String isDateTime;

  ListFilterAddDetails({this.label, this.fieldName, this.required, this.isDateTime});

  factory ListFilterAddDetails.fromJson(Map<String, dynamic> json) {
    return new ListFilterAddDetails(
      label: json['label'],
      fieldName: json['fieldName'],
      required: json['required'],
      isDateTime: json['isDateTime'],
    );
  }
}

class ListFilter {
  final String title;
  final String value;
  final String addURL;
  final List<ListFilterAddDetails> addDetails;

  ListFilter({this.title, this.value, this.addURL, this.addDetails});

  factory ListFilter.fromJson(Map<String, dynamic> json) {
    var jsonList = json['items'] as List;
    List<ListFilterAddDetails> list;
    if (jsonList != null) {
      list = jsonList.map((i) => ListFilterAddDetails.fromJson(i)).toList();
    }
    return new ListFilter(
      title: json['title'],
      value: json['value'],
      addURL: json['addURL'],
      addDetails: list,
    );
  }
}

class ListItem {
  final String label;
  final String labelColor;
  final String title;
  final String subtitle;
  final String dateTime;
  final String details;
  final String screenType;
  final String detailLink;
  final String photo;

  ListItem({this.label, this.labelColor, this.title, this.subtitle, this.dateTime, this.details, this.screenType, this.detailLink, this.photo});

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return new ListItem(
      label: json['label'],
      labelColor: json['labelColor'],
      title: json['title'],
      subtitle: json['subtitle'],
      dateTime: json['dateTime'],
      details: json['details'],
      screenType: json['screenType'],
      detailLink: json['detailLink'],
      photo: json['photo'],
    );
  }
}

class ListResponse {
  final List<ListFilter> filters;
  final List<ListItem> items;

  ListResponse({this.filters, this.items});

  factory ListResponse.fromJson(Map<String, dynamic> json) {
    var jsonFilters = json['filters'] as List;
    var jsonItems = json['items'] as List;
    List<ListFilter> filtersList;
    List<ListItem> itemsList;
    if (jsonFilters != null) {
      filtersList = jsonFilters.map((i) => ListFilter.fromJson(i)).toList();
    }
    if (jsonItems != null) {
      itemsList = jsonItems.map((i) => ListItem.fromJson(i)).toList();
    }
    return new ListResponse(
      filters: filtersList,
      items: itemsList,
    );
  }
}