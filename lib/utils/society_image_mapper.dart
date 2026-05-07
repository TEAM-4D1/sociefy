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
    'filmsociety': 'assets/animesoc.png', // Film uses anime theme as default
    'film': 'assets/animesoc.png',
    'chesssociety': 'assets/compscisoc.png', // Chess uses computer science theme
    'chess': 'assets/compscisoc.png',
    'dramasociety': 'assets/literaturesoc.png', // Drama uses literature theme
    'drama': 'assets/literaturesoc.png',
    'codingclub': 'assets/compscisoc.png', // Coding uses computer science
    'coding': 'assets/compscisoc.png',
    'basketballsociety': 'assets/badmintonsoc.png', // Basketball uses sports theme
    'basketball': 'assets/badmintonsoc.png',
  };

  return imageMap[name] ?? 'assets/animesoc.png'; // Default image
}
