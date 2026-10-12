import 'package:flutter/material.dart';

/// A form selector with a menu anchored below the full-width input.
class BilanqoDropdown<T> extends StatelessWidget {
  const BilanqoDropdown({
    super.key,
    this.initialValue,
    this.label,
    this.hint,
    this.leading,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final T? initialValue;
  final String? label, hint;
  final IconData? leading;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onChanged != null && items.any((item) => item.enabled);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: .6),
      ),
    );
    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      enabled: enabled,
      builder: (field) {
        final selectedIndex = items.indexWhere(
          (item) => item.value == field.value,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
            ],
            LayoutBuilder(
              builder: (context, constraints) => PopupMenuButton<int>(
                enabled: enabled,
                tooltip:
                    label ??
                    hint ??
                    (Localizations.localeOf(context).languageCode == 'it'
                        ? 'Seleziona'
                        : 'Select'),
                position: PopupMenuPosition.under,
                offset: const Offset(0, 6),
                constraints: BoxConstraints.tightFor(
                  width: constraints.maxWidth,
                ),
                color: colors.surfaceContainerLowest,
                surfaceTintColor: Colors.transparent,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: .4),
                  ),
                ),
                menuPadding: const EdgeInsets.all(8),
                padding: EdgeInsets.zero,
                onSelected: (index) {
                  field.didChange(items[index].value);
                  items[index].onTap?.call();
                  onChanged?.call(items[index].value);
                },
                itemBuilder: (context) => List.generate(
                  items.length,
                  (index) => PopupMenuItem<int>(
                    value: index,
                    enabled: items[index].enabled,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? colors.surfaceContainerLow
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DefaultTextStyle.merge(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: items[index].enabled
                                    ? colors.onSurface
                                    : colors.onSurfaceVariant.withValues(
                                        alpha: .4,
                                      ),
                                fontWeight: index == selectedIndex
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              child: items[index].child,
                            ),
                          ),
                          if (index == selectedIndex) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: colors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                child: InputDecorator(
                  isEmpty: selectedIndex < 0,
                  decoration: InputDecoration(
                    enabled: enabled,
                    errorText: field.errorText,
                    filled: true,
                    fillColor: colors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: border,
                    enabledBorder: border,
                    disabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    errorBorder: border.copyWith(
                      borderSide: BorderSide(color: colors.error),
                    ),
                    focusedErrorBorder: border.copyWith(
                      borderSide: BorderSide(color: colors.error, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        Icon(
                          leading,
                          size: 22,
                          color: enabled
                              ? colors.primary
                              : colors.onSurfaceVariant.withValues(alpha: .4),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: enabled
                                ? colors.onSurface
                                : colors.onSurfaceVariant.withValues(alpha: .4),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: selectedIndex >= 0
                              ? items[selectedIndex].child
                              : Text(
                                  hint ??
                                      (Localizations.localeOf(context)
                                                  .languageCode ==
                                              'it'
                                          ? 'Seleziona…'
                                          : 'Select…'),
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: enabled
                            ? colors.primary
                            : colors.onSurfaceVariant.withValues(alpha: .4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
