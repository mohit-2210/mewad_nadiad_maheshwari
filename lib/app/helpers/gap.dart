import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_spacing.dart';

class Gap extends StatelessWidget {
  final double height;
  final double width;

  const Gap._({this.height = 0, this.width = 0});

  /// Vertical gaps
  factory Gap.s4H() => Gap._(height: AppSpacing.s4);
  factory Gap.s8H() => Gap._(height: AppSpacing.s8);
  factory Gap.s10H() => Gap._(height: AppSpacing.s10);
  factory Gap.s12H() => Gap._(height: AppSpacing.s12);
  factory Gap.s16H() => Gap._(height: AppSpacing.s16);
  factory Gap.s20H() => Gap._(height: AppSpacing.s20);
  factory Gap.s24H() => Gap._(height: AppSpacing.s24);
  factory Gap.s30H() => Gap._(height: AppSpacing.s30);
  factory Gap.s32H() => Gap._(height: AppSpacing.s32);
  factory Gap.s40H() => Gap._(height: AppSpacing.s40);
  factory Gap.s48H() => Gap._(height: AppSpacing.s48);
  factory Gap.s64H() => Gap._(height: AppSpacing.s64);

  /// Horizontal gaps
  factory Gap.s4W() => Gap._(width: AppSpacing.s4);
  factory Gap.s8W() => Gap._(width: AppSpacing.s8);
  factory Gap.s10W() => Gap._(width: AppSpacing.s10);
  factory Gap.s12W() => Gap._(width: AppSpacing.s12);
  factory Gap.s16W() => Gap._(width: AppSpacing.s16);
  factory Gap.s20W() => Gap._(width: AppSpacing.s20);
  factory Gap.s24W() => Gap._(width: AppSpacing.s24);
  factory Gap.s30W() => Gap._(width: AppSpacing.s30);
  factory Gap.s32W() => Gap._(width: AppSpacing.s32);
  factory Gap.s40W() => Gap._(width: AppSpacing.s40);
  factory Gap.s48W() => Gap._(width: AppSpacing.s48);
  factory Gap.s64W() => Gap._(width: AppSpacing.s64);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}
