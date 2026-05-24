enum AccountType {
  personal('personal', 'Личный', 'Играю и записываюсь на турниры'),
  club('club', 'Клуб', 'Организую турниры и управляю площадкой');

  const AccountType(this.apiValue, this.title, this.subtitle);

  final String apiValue;
  final String title;
  final String subtitle;

  static AccountType fromApi(String? value) {
    return AccountType.values.firstWhere(
      (t) => t.apiValue == value,
      orElse: () => AccountType.personal,
    );
  }
}
