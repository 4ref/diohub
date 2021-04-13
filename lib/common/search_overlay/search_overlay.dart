import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:onehub/common/animations/size_expanded_widget.dart';
import 'package:onehub/common/overlay_menu_widget.dart';
import 'package:onehub/common/search_overlay/filters.dart';
import 'package:onehub/common/user_search_dropdown.dart';
import 'package:onehub/style/borderRadiuses.dart';
import 'package:onehub/style/colors.dart';
import 'package:onehub/style/text_field_themes.dart';

class SearchOverlayScreen extends StatefulWidget {
  final String? message;
  final ValueChanged<SearchData> onSubmit;
  final SearchData searchData;
  final SearchFilters? searchFilters;
  SearchOverlayScreen(this.searchData,
      {this.message, required this.onSubmit, this.searchFilters});
  @override
  _SearchOverlayScreenState createState() => _SearchOverlayScreenState();
}

class _SearchOverlayScreenState extends State<SearchOverlayScreen> {
  late SearchData searchData;
  late SearchFilters searchFilters;

  @override
  void initState() {
    searchFilters = widget.searchFilters ?? SearchFilters.repositories();
    searchData = widget.searchData;
    super.initState();
  }

  bool get isValid {
    bool isValid = false;
    searchData.filters.forEach((element) {
      if (element.qualifierQuery) isValid = true;
    });

    int numberOfAndOrNot = 0;
    searchData.query.splitMapJoin(
      RegExp(SearchFilters.notOperatorRegExp.pattern +
          '|' +
          SearchFilters.andOrOperatorsRegExp.pattern),
      onMatch: (Match m) {
        numberOfAndOrNot++;
        return '';
      },
    );
    return (isValid || searchData.query.trim().isNotEmpty) &&
        numberOfAndOrNot <= 5;
  }

  SearchFilters getFilters(SearchType type) {
    switch (type) {
      case SearchType.repositories:
        return SearchFilters.repositories();
      case SearchType.issues_pulls:
        return SearchFilters.issuesPulls();
      default:
        return SearchFilters.repositories();
    }
  }

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: _SearchBar(
                        widget.searchFilters ?? searchFilters,
                        widget.searchData,
                        onChanged: (data) {
                          setState(() {
                            searchData = data;
                          });
                        },
                        message: widget.message,
                      ),
                    ),
                  ),
                  if (widget.searchFilters == null)
                    Divider(
                      height: 0,
                    ),
                  if (widget.searchFilters == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                                'Searching in ${searchTypeValues.reverse![searchFilters.searchType]}'),
                            onTap: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            trailing: Icon(expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded),
                          ),
                          SizeExpandedSection(
                            expand: expanded,
                            child: ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return RadioListTile(
                                    activeColor: AppColor.accent,
                                    groupValue: searchFilters.searchType,
                                    value: searchTypeValues.map.values
                                        .toList()[index],
                                    onChanged: (value) {
                                      setState(() {
                                        searchFilters = getFilters(
                                            searchTypeValues.map.values
                                                .toList()[index]);
                                        expanded = !expanded;
                                      });
                                    },
                                    title: Text(
                                      searchTypeValues.map.keys.toList()[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(),
                                itemCount: searchTypeValues.map.keys.length),
                          ),
                        ],
                      ),
                    ),
                  Divider(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'How to format your filters',
                          style: TextStyle(fontSize: 14, color: AppColor.grey3),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Divider(),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                        text:
                                            'Search filters should be in the format '),
                                    TextSpan(
                                        text: 'filter:"data"',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '.\n'),
                                    TextSpan(
                                        text:
                                            'Example, label:"enhancement" will include all results with a label named enhancement.',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ]),
                                  style: TextStyle(
                                      fontSize: 13, color: AppColor.grey3),
                                ),
                                Divider(),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: 'Add a '),
                                    TextSpan(
                                        text: 'minus (-)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            ' before a search filter to exclude it from the results.\n'),
                                    TextSpan(
                                        text:
                                            'Example, -label:"enhancement" will exclude all results with a label named enhancement.',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ]),
                                  style: TextStyle(
                                      fontSize: 13, color: AppColor.grey3),
                                ),
                                Divider(),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: 'You can use '),
                                    TextSpan(
                                        text: 'AND, OR, NOT',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: ' operators in your query '),
                                    TextSpan(
                                        text: '(upto a maximum of 5 times)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '.\n'),
                                    TextSpan(
                                        text:
                                            'Example, "jquery NOT bootstrap" matches results that do contain the word "jquery" but not "bootstrap".',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ]),
                                  style: TextStyle(
                                      fontSize: 13, color: AppColor.grey3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: 'homeNavButton',
                      child: ClipOval(
                        child: Material(
                          color: AppColor.onBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: IconButton(
                              iconSize: 25,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(LineIcons.times),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: 'searchNavButton',
                      child: ClipOval(
                        child: Material(
                          elevation: 2,
                          color: AppColor.onBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: IconButton(
                              iconSize: 25,
                              onPressed: isValid
                                  ? () {
                                      Navigator.pop(context);
                                      widget.onSubmit(SearchData());
                                    }
                                  : null,
                              icon: Icon(LineIcons.search),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final SearchFilters searchFilters;
  final SearchData searchData;

  final String? message;
  final ValueChanged<SearchData> onChanged;
  _SearchBar(this.searchFilters, this.searchData,
      {this.message, required this.onChanged});
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  FocusNode searchNode = FocusNode();
  late TextEditingController controller;
  late SearchData searchData;
  @override
  void initState() {
    searchData = widget.searchData;
    controller = TextEditingController(text: widget.searchData.toString());
    getFocus();
    searchNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          OverlayMenuWidget(
            controller: suggestionsOverlayController,
            overlay: overlayWidget,
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: ExtendedTextField(
                  controller: controller,
                  maxLines: 10,
                  focusNode: searchNode,
                  minLines: 2,
                  onChanged: (pattern) {
                    if (pattern.contains('\n')) {
                      controller.text = controller.text.replaceAll('\n', '');
                      if (controller.text.endsWith('"'))
                        controller.text = controller.text + ' ';
                      _moveControllerToEnd();
                    }
                    if (pattern.trim().isEmpty)
                      controller.text = controller.text.trim();
                    _parseQuery(pattern);
                    _suggestions(pattern);
                  },
                  specialTextSpanBuilder:
                      _TextSpanBuilder(widget.searchFilters, controller),
                  decoration: TextFieldTheme.inputDecoration(
                      hintText: widget.message,
                      icon: LineIcons.search,
                      labelText: 'Searching For',
                      focusNode: searchNode),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('All Queries'),
                  onTap: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  trailing: Icon(expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded),
                ),
                SizeExpandedSection(
                  expand: expanded,
                  child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            addString(
                                widget.searchFilters.whiteListedQueries[index]
                                        .query +
                                    ':',
                                addSpaceAtEnd: false,
                                spaceAtStart: true);
                            setState(() {
                              expanded = false;
                            });
                            searchNode.requestFocus();
                          },
                          title: Text(
                            widget
                                .searchFilters.whiteListedQueries[index].query,
                            // style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount:
                          widget.searchFilters.whiteListedQueries.length),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
          //   child: Material(
          //     elevation: 2,
          //     borderRadius: AppThemeBorderRadius.medBorderRadius,
          //     color: AppColor.onBackground,
          //     child: Padding(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          //       child: DropdownButton<String>(
          //           isExpanded: true,
          //           value: 'created-desc',
          //           onChanged: (String? newValue) {
          //             setState(() {});
          //           },
          //           dropdownColor: AppColor.onBackground,
          //           underline: Container(),
          //           items: widget.searchFilters.sortOptions.entries.map((e) {
          //             return DropdownMenuItem<String>(
          //               value: e.key,
          //               child: Text(e.value),
          //             );
          //           }).toList()),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void getFocus() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted)
      setState(() {
        searchNode.requestFocus();
      });
  }

  void addString(
    String data, {
    bool addSpaceAtEnd = true,
    bool spaceAtStart = false,
    bool addQuotesAtEnd = false,
    bool addQuotesAround = false,
    String remove = '',
  }) {
    controller.text =
        controller.text.substring(0, controller.text.length - remove.length);
    controller.text = controller.text +
        '${spaceAtStart ? ' ' : ''}${addQuotesAround ? '"' : ''}$data${addQuotesAround ? '"' : ''}${addSpaceAtEnd ? ' ' : ''}' +
        '${addQuotesAtEnd ? '""' : ''}';
    _moveControllerToEnd(addQuotesAtEnd ? 1 : 0);
    searchNode.requestFocus();
    _parseQuery(controller.text);
    _suggestions(controller.text);
  }

  void _moveControllerToEnd([int offset = 0]) {
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length - offset),
    );
  }

  bool isEndSame(String initial, String part) {
    return initial.substring(initial.length - part.length) == part;
  }

  List<String> getMatches(RegExp regexp, String pattern) {
    List<String> matches = [];
    pattern.splitMapJoin(regexp, onMatch: (Match m) {
      matches.add(m.group(0)!);
      return m.group(0)!;
    });
    return matches;
  }

  Widget list(int length, builder, {Key? key}) {
    return SizeExpandedSection(
      key: key,
      child: Material(
        color: AppColor.onBackground,
        borderRadius: AppThemeBorderRadius.medBorderRadius,
        elevation: 8,
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return builder(context, index);
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
              );
            },
            itemCount: length),
      ),
    );
  }

  OverlayController suggestionsOverlayController = OverlayController();
  Widget overlayWidget = Container();

  void _showOverlay(Widget widget) {
    setState(() {
      overlayWidget = widget;
      suggestionsOverlayController.open();
    });
  }

  void _closeOverlay() {
    setState(() {
      overlayWidget = Container();
      suggestionsOverlayController.close();
    });
  }

  void _parseQuery(String pattern) {
    List<String> filterStrings = [];
    List<SearchQuery> filters = [];
    pattern.splitMapJoin(widget.searchFilters.allValidQueriesRegexp,
        onMatch: (Match m) {
      filterStrings.add(m[0]!);
      filters
          .add(widget.searchFilters.queryFromString(m[0]!.split(':').first)!);
      return '';
    });
    pattern =
        pattern.replaceAll(widget.searchFilters.allInvalidQueriesRegExp, '');
    pattern = pattern.replaceAll(RegExp('(\\s+)'), ' ');
    widget.onChanged(searchData.copyWith(
        query: pattern, filterStrings: filterStrings, filters: filters));
  }

  void _suggestions(String pattern) {
    _closeOverlay();
    // if (pattern.isEmpty) return [];
    // Get matches on the option queries on the supplied text.
    if (controller.selection.baseOffset == controller.text.length) {
      List<String> matches = getMatches(
          RegExp(
              '${widget.searchFilters.validSensitiveQueriesRegExp.pattern}|${widget.searchFilters.invalidSensitiveQueriesRegExp.pattern}'),
          pattern);
      String typedData = '';
      SearchQuery? query;
      matches.forEach(
        (element) {
          if (isEndSame(pattern, element)) {
            typedData = element.substring(0).split(':')[1];
            String queryString = element.split(':').first;
            if (queryString.startsWith('-'))
              queryString = queryString.substring(1);
            query = widget.searchFilters.queryFromString(queryString);
          }
        },
      );
      List<String?> completedQueries = getMatches(
          RegExp(
              '${widget.searchFilters.validSensitiveQueriesRegExp.pattern}|${widget.searchFilters.invalidSensitiveQueriesRegExp.pattern}|${widget.searchFilters.validBasicQueriesRegExp.pattern}'),
          pattern);
      bool isLastQueryActive = completedQueries.isNotEmpty &&
          isEndSame(pattern, completedQueries.last!);
      if (!isLastQueryActive) {
        List<String> filteredOptions = [];
        typedData = pattern.split(' ').last;
        if (typedData.startsWith('-')) typedData = typedData.substring(1);
        if (typedData.isNotEmpty) {
          widget.searchFilters.whiteListedQueriesStrings.forEach((element) {
            if (element.startsWith(typedData)) filteredOptions.add(element);
          });

          _showOverlay(list(filteredOptions.length, (context, index) {
            return ListTile(
              onTap: () {
                SearchQuery query = widget.searchFilters
                    .queryFromString(filteredOptions[index])!;
                addString(filteredOptions[index] + ':',
                    addQuotesAtEnd: query.options == null &&
                        (query.type == QueryType.basic ||
                            query.type == QueryType.spacedString),
                    addSpaceAtEnd: false,
                    remove: typedData);
              },
              title: Text(
                filteredOptions[index] + ':',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }, key: Key(typedData)));
        }
      } else if (query?.type == QueryType.number && (typedData.isEmpty)) {
        // return [0, typedData];
      } else if ((query?.type == QueryType.user ||
              query?.type == QueryType.org) &&
          !typedData.endsWith(' '))
        _showOverlay(UserSearchDropdown(
          typedData,
          onSelected: (data) {
            addString(data, remove: typedData, addQuotesAround: true);
          },
          type: query!.type,
        ));
      else if (query?.options?.keys != null) {
        List<String> filteredOptions = [];
        query!.options?.keys.toList().forEach(
          (element) {
            if (element.startsWith(typedData)) filteredOptions.add(element);
          },
        );
        _showOverlay(list(filteredOptions.length, (context, index) {
          return ListTile(
            onTap: () {
              addString(filteredOptions[index],
                  addSpaceAtEnd: true, remove: typedData);
            },
            title: Text(filteredOptions[index]),
          );
        }, key: Key(typedData)));
        // return [OptionsSuggestion(filteredOptions, typedData)];
      }
    }
    // return <String>[];
  }
}

class _TextSpanBuilder extends SpecialTextSpanBuilder {
  _TextSpanBuilder(this.searchFilters, this.controller)
      : patternMap = {
          searchFilters.validSensitiveQueriesRegExp: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          searchFilters.validBasicQueriesRegExp: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        },
        blacklistPatternMap = {
          searchFilters.invalidSensitiveQueriesRegExp: TextStyle(
              color: AppColor.grey3,
              decoration: TextDecoration.combine([TextDecoration.lineThrough])),
          searchFilters.invalidBasicQueriesRegExp: TextStyle(
              color: AppColor.grey3,
              decoration: TextDecoration.combine([TextDecoration.lineThrough])),
          searchFilters.blacklistRegExp: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.combine([TextDecoration.lineThrough]),
          ),
        };
  final SearchFilters searchFilters;
  final Map<RegExp, TextStyle> patternMap;
  final Map<RegExp, TextStyle> blacklistPatternMap;
  final TextEditingController controller;
  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    if (data == '') {
      return const TextSpan(text: '');
    }
    final List<InlineSpan> inlineList = <InlineSpan>[];
    if (data.isNotEmpty) {
      data.splitMapJoin(searchFilters.allValidQueriesRegexp,
          onMatch: (Match m) {
        inlineList
            .add(_ValidQuery(m[0]!, 1, controller, textStyle).finishText());
        return '';
      }, onNonMatch: (String string) {
        string.splitMapJoin(
            RegExp(SearchFilters.notOperatorRegExp.pattern +
                '|' +
                SearchFilters.andOrOperatorsRegExp.pattern),
            onMatch: (Match m) {
          inlineList.add(getSpan(
              m[0]!,
              textStyle!.copyWith(
                  color:
                      m[0]!.startsWith('NOT') ? AppColor.red : AppColor.accent,
                  fontWeight: FontWeight.bold)));
          return '';
        }, onNonMatch: (String string) {
          inlineList.add(getSpan(string, textStyle));
          return '';
        });
        return '';
      });
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }
    return TextSpan(children: inlineList, style: textStyle);
  }

  TextSpan getSpan(String text, TextStyle? style) {
    List<TextSpan> children = [];
    List<String> matches = [];
    RegExp? allRegex;
    String wlRegex = patternMap.keys.map((e) => e.pattern).join('|');
    String blRegex = blacklistPatternMap.keys.map((e) => e.pattern).join('|');
    Map<RegExp, TextStyle> combinedMap = {};
    combinedMap.addAll(patternMap);
    combinedMap.addAll(blacklistPatternMap);
    allRegex = RegExp('$wlRegex|$blRegex');
    text.splitMapJoin(
      allRegex,
      onMatch: (Match m) {
        if (!matches.contains(m[0])) matches.add(m[0]!);
        RegExp? k = combinedMap.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;
        children.add(
          TextSpan(
            text: m[0],
            style: combinedMap[k],
          ),
        );
        return '';
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span.toString();
      },
    );
    return TextSpan(style: style, children: children);
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, onTap, required int index}) {}
}

class _ValidQuery extends SpecialText {
  _ValidQuery(
      String startFlag, this.start, this.controller, TextStyle? textStyle)
      : super(
          startFlag,
          '',
          textStyle ?? TextStyle(),
        );

  final TextEditingController controller;

  @override
  bool isEnd(String value) {
    return toString().trim().endsWith('"');
  }

  final int start;

  @override
  InlineSpan finishText() {
    return ExtendedWidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Material(
            borderRadius: AppThemeBorderRadius.smallBorderRadius,
            color: toString().startsWith('-') ? AppColor.red : AppColor.accent,
            child: InkWell(
              borderRadius: AppThemeBorderRadius.smallBorderRadius,
              onTap: () {
                controller.text = controller.text.replaceFirst(toString(), '');
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
                if (controller.text.trim().isEmpty)
                  controller.text = controller.text.trim();
                HapticFeedback.vibrate();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 2.0, left: 6, right: 6, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: RichText(
                      text: TextSpan(
                          style: textStyle.copyWith(fontSize: 14),
                          children: [
                            TextSpan(
                                text: toString()
                                        .trim()
                                        .replaceAll('"', '')
                                        .split(':')
                                        .first +
                                    ' ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: toString()
                                    .trim()
                                    .replaceAll('"', '')
                                    .split(':')
                                    .last),
                          ]),
                    )),
                    SizedBox(
                      width: 4,
                    ),
                    ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: Icon(
                          Icons.close_rounded,
                          color: toString().startsWith('-')
                              ? AppColor.red
                              : AppColor.accent,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
      start: start,
      actualText: toString(),
      deleteAll: false,
    );
  }
}

class SearchData {
  final String query;
  final List<String> filterStrings;
  final List<SearchQuery> filters;
  SearchData(
      {this.query = '',
      this.filterStrings = const [],
      this.filters = const []});

  @override
  String toString() {
    return query.trim() + ' ' + filterStrings.join(' ').trim();
  }

  SearchData copyWith(
      {String? query,
      List<String>? filterStrings,
      List<SearchQuery>? filters}) {
    return SearchData(
        filters: filters ?? this.filters,
        query: query ?? this.query,
        filterStrings: filterStrings ?? this.filterStrings);
  }
}
