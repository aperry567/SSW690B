class USState{
  const USState(this.name);
  final String name;
}

class SecretQuestion{
  const SecretQuestion(this.name);
  final String name;
}

class EnumList{
  static const List<USState> us_states_list =
  [
    const USState("AL"), const USState("AK"), const USState("AZ"), const USState("AR"), const USState("CA"), const USState("CO"), const USState("CT"), const USState("DE"), const USState("FL"), const USState("GA"),
  const USState("HI"), const USState("ID"), const USState("IL"), const USState("IN"), const USState("IA"), const USState("KS"), const USState("KY"), const USState("LA"), const USState("ME"), const USState("MD"),
  const USState("MA"), const USState("MI"), const USState("MN"), const USState("MS"), const USState("MO"), const USState("MT"), const USState("NE"), const USState("NV"), const USState("NH"), const USState("NJ"),
  const USState("NM"), const USState("NY"), const USState("NC"), const USState("ND"), const USState("OH"), const USState("OK"), const USState("OR"), const USState("PA"), const USState("RI"), const USState("SC"),
  const USState("SD"), const USState("TN"), const USState("TX"), const USState("UT"), const USState("VT"), const USState("VA"), const USState("WA"), const USState("WV"), const USState("WI"), const USState("WY")
  ];

  static const List<SecretQuestion> secret_question =
  [
    const SecretQuestion("What is your first pet name? "),
    const SecretQuestion("What is the name of your college? "),
    const SecretQuestion("What was your childhood nickname? "),
    const SecretQuestion("Where were you when you had your first kiss? "),
    const SecretQuestion("What is the name of your favorite childhood friend? "),
  ];








}