import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  /// Page controller to control [PageView] widget
  final PageController controller;

  /// List of [SideMenuItem] to show them on [SideMenu]
  final List<SideMenuItem> items;

  /// Title widget will shows on top of all items,
  /// it can be a logo or a Title text
  final Widget? title;

  /// Footer widget will show on bottom of [SideMenu]
  /// when [displayMode] was SideMenuDisplayMode.open
  final Widget? footer;

  /// [SideMenu] can be configured by this
  final SideMenuStyle? style;

  /// ### Easy Sidemenu widget
  ///
  /// Sidemenu is a menu that is usually located
  /// on the left or right of the page and can used for navigations
  const SideMenu({
    Key? key,
    required this.items,
    required this.controller,
    this.title,
    this.footer,
    this.style,
  }) : super(key: key);

  /// Set [SideMenu] width according to displayMode
  double _widthSize(SideMenuDisplayMode mode, BuildContext context) {
    if (mode == SideMenuDisplayMode.auto) {
      if (MediaQuery.of(context).size.width > 600) {
        Global.displayModeState.change(SideMenuDisplayMode.open);
        return Global.style.openSideMenuWidth ?? 300;
      } else {
        Global.displayModeState.change(SideMenuDisplayMode.compact);
        return Global.style.compactSideMenuWidth ?? 50;
      }
    } else if (mode == SideMenuDisplayMode.open) {
      Global.displayModeState.change(SideMenuDisplayMode.open);
      return Global.style.openSideMenuWidth ?? 300;
    } else {
      Global.displayModeState.change(SideMenuDisplayMode.compact);
      return Global.style.compactSideMenuWidth ?? 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    Global.controller = controller;
    items.sort((a, b) => a.priority.compareTo(b.priority));
    Global.style = style ?? SideMenuStyle();

    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      width: _widthSize(
          Global.style.displayMode ?? SideMenuDisplayMode.auto, context),
      height: MediaQuery.of(context).size.height,
      color: Global.style.backgroundColor ?? null,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (title != null) title!,
                ...items,
              ],
            ),
          ),
          if (footer != null &&
              Global.displayModeState.value != SideMenuDisplayMode.compact)
            Align(alignment: Alignment.bottomCenter, child: footer!),
        ],
      ),
    );
  }
}

class Global {
  static late PageController controller;
  static late SideMenuStyle style;
  static DisplayModeNotifier displayModeState =
      DisplayModeNotifier(SideMenuDisplayMode.auto);
}

class DisplayModeNotifier extends ValueNotifier<SideMenuDisplayMode> {
  DisplayModeNotifier(SideMenuDisplayMode value) : super(value);

  void change(SideMenuDisplayMode mode) {
    value = mode;
    notifyListeners();
  }
}

enum SideMenuDisplayMode {
  /// Let the [Sidemenu] decide what display mode should be used
  /// based on the width. This is used by default on [Sidemenu].
  /// In Auto mode, the [Sidemenu] adapts between [compact],
  ///  and then [open] as the window gets wider.
  auto,

  /// The pane is expanded and positioned to the left of the content.
  ///
  /// Use open mode when:
  ///   * You have 5-10 equally important top-level navigation categories.
  ///   * You want navigation categories to be very prominent, with less
  ///     space for other app content.
  open,

  /// The [Sidemenu] shows only icons until opened and is positioned to the left
  /// of the content.
  compact
}

class SideMenuItem extends StatefulWidget {
  /// #### Side Menu Item
  ///
  /// This is a widget as [SideMenu] items with text and icon
  const SideMenuItem({
    Key? key,
    required this.onTap,
    required this.title,
    this.icon,
    required this.priority,
  }) : super(key: key);

  /// A function that call when tap on [SideMenuItem]
  final Function onTap;

  /// Title text
  final String title;

  /// A Icon to display before [title]
  final IconData? icon;

  /// Priority of item to show on [SideMenu], lower value is displayed at the top
  ///
  /// * Start from 0
  /// * This value should be unique
  /// * This value used for page controller index
  final int priority;

  @override
  _SideMenuItemState createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<SideMenuItem> {
  double curentPage = 0;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    Global.controller.addListener(() {
      setState(() {
        curentPage = Global.controller.page!;
      });
    });
  }

  /// Set background color of [SideMenuItem]
  Color _setColor() {
    if (widget.priority == curentPage) {
      return Global.style.selectedColor ?? Theme.of(context).highlightColor;
    } else if (isHovered) {
      return Global.style.hoverColor ?? Colors.transparent;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _setColor(),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: ValueListenableBuilder(
            valueListenable: Global.displayModeState,
            builder: (context, value, child) {
              return Padding(
                padding: value == SideMenuDisplayMode.compact
                    ? const EdgeInsets.only(left: 8.0)
                    : const EdgeInsets.only(left: 8.0, bottom: 8, top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (widget.icon != null)
                        ? Icon(
                            widget.icon,
                            color: widget.priority == curentPage
                                ? Global.style.selectedIconColor ?? Colors.black
                                : Global.style.unselectedIconColor ??
                                    Colors.black54,
                            size: Global.style.iconSize ?? 24,
                          )
                        : Center(child: Text(widget.title.substring(0, 3))),
                    const SizedBox(
                      width: 8.0,
                    ),
                    if (value == SideMenuDisplayMode.open)
                      Expanded(
                        child: Text(
                          widget.title,
                          style: widget.priority == curentPage
                              ? const TextStyle(
                                      fontSize: 17, color: Colors.black)
                                  .merge(Global.style.selectedTitleTextStyle)
                              : const TextStyle(
                                      fontSize: 17, color: Colors.black54)
                                  .merge(Global.style.unselectedTitleTextStyle),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      onTap: () => widget.onTap(),
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}

class SideMenuStyle {
  /// Width of [SideMenu] when [displayMode] was SideMenuDisplayMode.open
  double? openSideMenuWidth;

  /// Width of [SideMenu] when [displayMode] was SideMenuDisplayMode.compact
  double? compactSideMenuWidth;

  /// Background color of [SideMenu]
  Color? backgroundColor;

  /// Background color of [SideMenuItem] when item is selected
  Color? selectedColor;

  /// Color of [SideMenuItem] when mouse hover on that
  Color? hoverColor;

  /// You can use the [displayMode] property to configure different
  /// display modes for the [SideMenu]
  SideMenuDisplayMode? displayMode;

  /// Style of [title] text when item is selected
  TextStyle? selectedTitleTextStyle;

  /// Style of [title] text when item is unselected
  TextStyle? unselectedTitleTextStyle;

  /// Color of icon when item is selected
  Color? selectedIconColor;

  /// Color of icon when item is unselected
  Color? unselectedIconColor;

  /// Size of icon on [SideMenuItem]
  double? iconSize;

  /// Style class to configure [SideMenu]
  SideMenuStyle({
    this.openSideMenuWidth = 300,
    this.compactSideMenuWidth = 50,
    this.backgroundColor,
    this.selectedColor,
    this.hoverColor = Colors.transparent,
    this.displayMode = SideMenuDisplayMode.auto,
    this.selectedTitleTextStyle,
    this.unselectedTitleTextStyle,
    this.selectedIconColor = Colors.black,
    this.unselectedIconColor = Colors.black54,
    this.iconSize = 24,
  });
}
