import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {

  // 🔹 TEXT HELPERS (THEME-DRIVEN)
  static TextStyle heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!;

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle subText(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : AppColors.textSecondary,
      );

  // 🔹 STANDARD PADDING
  static const EdgeInsets pagePadding =
  EdgeInsets.symmetric(horizontal: 16, vertical: 16);

  static const EdgeInsets cardPadding =
  EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  // 🔹 MAIN CARD (USED EVERYWHERE)
  static BoxDecoration card(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05,
        ),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // 🔹 SOFT CARD (LIST / ROW ITEMS)
  static BoxDecoration softCard(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Theme.of(context).dividerColor,
    ),
  );

  // 🔹 DIVIDER
  static Divider divider(BuildContext context) => Divider(
    color: Theme.of(context).dividerColor,
    height: 24,
    thickness: 1,
  );

  // 🔹 BRAND GRADIENT (OPTIONAL)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0xFFFF9A5C),
    ],
  );
}
