const String storyAssetsDir = 'assets/our_story';

/// id → filename inside assets/Our Story/. Stays local — images ship
/// with the app, not with the backend.
const Map<String, String> storyImageFilenames = {
  '1891': '1891.png',
  '1893': '1893.png',
  '1898': '1898.png',
  '1900': '1900.png',
  '1901': '1901.png',
  '1904': '1904.png',
  '1909': '1909.png',
  '1914': '1914.png',
  '1924': '1924.png',
  '1925': '1925.png',
  '1928': '1928.png',
  '1930': '1930.png',
  '1932': '1932.png',
  '1933_smith': '1933-2.png',
  '1933_cycar': '1933.png',
  '1936': '1936.png',
  '1943': '1943.png',
  '1948': '1948.png',
  '1952_brittain': '1952-1.png',
  '1952_army': '1952.png',
  '1955': '1955.png',
  '1956': '1956.png',
  '1957': '1957.png',
  '1964': '1964.png',
  '1977': '1977.png',
  '1989': '1989.png',
  '1993': '1993.png',
  '1994': '1994.png',
  '1997': '1997.png',
  '2001_engine': '2001-1.png',
  '2001_daredevils': '2001.png',
  '2002': '2002.png',
  '2004': '2004.png',
  '2011': '2011.png',
  '2012': '2012.png',
  '2013_oragadam': '2013-1.png',
  '2013_gt': '2013.png',
  '2015_harris': '2015-1.png',
  '2015_na': '2015.png',
  '2016': '2016.png',
  '2017_uktc': '2017-1.png',
  '2017_vallam': '2017-2.png',
  '2017_twins': '2017.png',
  '2018_pegasus': '2018-1.png',
  '2018_bonneville': '2018-2.png',
  '2019_kx': '2019-1.png',
  '2019_karakoram': '2019.png',
  '2020_uce': '2020-2.png',
  '2020_meteor': '2020.png',
  '2021': '2021.png',
  '2022': '2022-royal-enfield-hunter-350.png',
  '2023': '2023-royal-enfield-super-meteor-650.png',
  '2024': '2024-royal-enfield-guerrilla-450.png',
};

class StoryEra {
  final String label;
  final String key;
  const StoryEra({required this.label, required this.key});
}

const List<StoryEra> storyEras = [
  StoryEra(label: '1890-1910', key: 'e1890'),
  StoryEra(label: '1911-1930', key: 'e1911'),
  StoryEra(label: '1931-1950', key: 'e1931'),
  StoryEra(label: '1951-1970', key: 'e1951'),
  StoryEra(label: '1971-1990', key: 'e1971'),
  StoryEra(label: '1991-2010', key: 'e1991'),
  StoryEra(label: '2011-2025', key: 'e2011'),
];

class StoryEntry {
  final String id;
  final String year;
  final String eraKey;
  final String description;

  const StoryEntry({
    required this.id,
    required this.year,
    required this.eraKey,
    required this.description,
  });

  /// Backend sends id/year/eraKey/description; the photo filename is
  /// resolved locally so the API never has to know about assets.
  factory StoryEntry.fromJson(Map<String, dynamic> json) => StoryEntry(
    id: json['id'] as String,
    year: json['year'] as String,
    eraKey: json['era_key'] as String,
    description: json['description'] as String,
  );

  String get imageAsset =>
      '$storyAssetsDir/${storyImageFilenames[id] ?? '$id.png'}';
}
