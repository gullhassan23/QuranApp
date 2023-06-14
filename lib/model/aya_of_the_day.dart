class AyaOfTheDay {
  final String? arText;
  final String? enTran;
  final String? surEnName;
  final int? surName;

  AyaOfTheDay(this.arText, this.enTran, this.surEnName, this.surName);

  factory AyaOfTheDay.fromJSON(Map<String, dynamic> json) {
    return AyaOfTheDay(
        json['data'][0]['text'],
        json['data'][2]['text'],
        json['data'][2]['surah']['englishName'],
        json['data'][2]['numberInsurah']);
  }
}
