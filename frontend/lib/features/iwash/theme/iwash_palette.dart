import 'package:flutter/material.dart';

class IWashPalette {
  final Color pageBackground;
  final Color mapBackground;
  final Color card;

  final Color primaryText;
  final Color secondaryText;

  final Color road;

  final Color waitingArea;
  final Color waitingBorder;

  final Color freeBay;
  final Color freeBorder;
  final Color freeAccent;
  final Color freeText;

  final Color occupiedBay;
  final Color occupiedBorder;
  final Color occupiedAccent;

  final Color parkingBackground;
  final Color parkingBorder;

  final Color carDark;

  const IWashPalette({
    required this.pageBackground,
    required this.mapBackground,
    required this.card,
    required this.primaryText,
    required this.secondaryText,
    required this.road,
    required this.waitingArea,
    required this.waitingBorder,
    required this.freeBay,
    required this.freeBorder,
    required this.freeAccent,
    required this.freeText,
    required this.occupiedBay,
    required this.occupiedBorder,
    required this.occupiedAccent,
    required this.parkingBackground,
    required this.parkingBorder,
    required this.carDark,
  });

  const IWashPalette.day()
      : pageBackground = const Color(0xFFECE8DF),
        mapBackground = const Color(0xFFDCE5D9),
        card = const Color(0xFFF7F4EE),
        primaryText = const Color(0xFF193A31),
        secondaryText = const Color(0xFF65756E),
        road = const Color(0xFFC7D0C4),
        waitingArea = const Color(0xFF505B57),
        waitingBorder = const Color(0xFF6F7D78),
        freeBay = const Color(0xFFCDE9DA),
        freeBorder = const Color(0xFF91CBAE),
        freeAccent = const Color(0xFF38C98D),
        freeText = const Color(0xFF287A5B),
        occupiedBay = const Color(0xFFF6C8BE),
        occupiedBorder = const Color(0xFFECA798),
        occupiedAccent = const Color(0xFFFF6B64),
        parkingBackground = const Color(0xFFEFF2EC),
        parkingBorder = const Color(0xFFC5CEC3),
        carDark = const Color(0xFF122621);

  const IWashPalette.night()
      : pageBackground = const Color(0xFF0D1414),
        mapBackground = const Color(0xFF0E1717),
        card = const Color(0xFF172020),
        primaryText = const Color(0xFFE7ECE9),
        secondaryText = const Color(0xFF7F9290),
        road = const Color(0xFF182426),
        waitingArea = const Color(0xFF111A1B),
        waitingBorder = const Color(0xFF304044),
        freeBay = const Color(0xFF12251F),
        freeBorder = const Color(0xFF1D4033),
        freeAccent = const Color(0xFF42E3A1),
        freeText = const Color(0xFF42E3A1),
        occupiedBay = const Color(0xFF2B1B1B),
        occupiedBorder = const Color(0xFF472A28),
        occupiedAccent = const Color(0xFFFF6C67),
        parkingBackground = const Color(0xFF111A1C),
        parkingBorder = const Color(0xFF243236),
        carDark = const Color(0xFF10201D);
}