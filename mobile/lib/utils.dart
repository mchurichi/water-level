import 'dart:io';
import 'dart:core';

class Utils {
  static InternetAddress parseIpAddress(String input) {
    var regex = new RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    var match = regex.firstMatch(input);
    if (match != null) {
      try {
        return new InternetAddress(match.group(0));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}