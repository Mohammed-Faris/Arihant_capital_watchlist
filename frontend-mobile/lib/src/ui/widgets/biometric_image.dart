import 'package:flutter/material.dart';

import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';

class BiometricImage extends StatelessWidget {
  const BiometricImage({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          height: 150.w,
          width: 150.w,
          child: AppImages.biometricAuth(context)),
    );
  }
}

class BiometricImageSmall extends StatelessWidget {
  const BiometricImageSmall({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
          turns: const AlwaysStoppedAnimation(0 / 360),
          child: SizedBox(
              height: 25.w,
              width: 25.w,
              child: AppImages.biometricAuth(context))),
    );
  }
}
