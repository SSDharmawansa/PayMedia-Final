class NicCalculation{
  static DateTime? calculateBirthdayFromNIC(String nic) {
    int year, dayOfYear;

    if (nic.length == 10) {
      year = 1900 + int.parse(nic.substring(0, 2));
      dayOfYear = int.parse(nic.substring(2, 5));
      if (dayOfYear > 500) {
        dayOfYear -= 500; // Female
      }
    } else if (nic.length == 12) {
      year = int.parse(nic.substring(0, 4));
      dayOfYear = int.parse(nic.substring(4, 7));
      if (dayOfYear > 500) {
        dayOfYear -= 500; // Female
      }
    } else {
      return null;
    }

    if (!isLeapYear(year) && dayOfYear > 59) {

      dayOfYear -= 1;
    }

    return DateTime(year, 1, 1).add(Duration(days: dayOfYear - 1));
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
  }

}