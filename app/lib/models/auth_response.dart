class AuthNav {
  final String title;
  final String icon;
  final String apiURL;
  final String screenType;

  AuthNav({this.title, this.icon, this.apiURL, this.screenType});

  factory AuthNav.fromJson(Map<String, dynamic> json) {
    return new AuthNav(
      title: json['title'],
      icon: json['icon'],
      apiURL: json['apiURL'],
      screenType: json['screenType']
    );
  }
}

class AuthResponse {
  final String sessionID;
  final String role;
  final List<AuthNav> nav;

  AuthResponse({this.sessionID, this.role, this.nav});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    var jsonList = json['nav'] as List;
    List<AuthNav> navList;
    if (jsonList != null) {
      navList = jsonList.map((i) => AuthNav.fromJson(i)).toList();
    }
    return new AuthResponse(
      sessionID: json['sessionID'],
      role: json['role'],
      nav: navList,
    );
  }
}