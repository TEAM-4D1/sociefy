/// Maps society names to their corresponding asset image paths.
String getSocietyImageAsset(String societyName) {
  final name = societyName.toLowerCase().replaceAll(' ', '');

  // Map society names to their image assets
  const imageMap = {
    'anime': 'assets/animesoc.png',
    'animesociety': 'assets/animesoc.png',
    'badminton': 'assets/badmintonsoc.png',
    'badmintonsociety': 'assets/badmintonsoc.png',
    'computerscience': 'assets/compscisoc.png',
    'compscisociety': 'assets/compscisoc.png',
    'literature': 'assets/literaturesoc.png',
    'literaturesociety': 'assets/literaturesoc.png',
    'mma': 'assets/mmasoc.png',
    'mmasociety': 'assets/mmasoc.png',
    'southasian': 'assets/southasiansoc.png',
    'southasiansociety': 'assets/southasiansoc.png',
  };

  return imageMap[name] ?? 'assets/animesoc.png'; // Default image
}
