class PortionUtils {
  static double gramsPerUnit(String unit) {
    switch (unit) {
      case 'roti':
        return 40;   // 1 medium chapati
      case 'bowl':
        return 180;
      case 'cup':
        return 150;  // cooked rice / dal
      case 'glass':
        return 200;  // milk (Indian glass)
      case 'piece':
        return 55;   // egg / banana average
      case 'grams':
        return 1;
      default:
        return 100;
    }
  }
}