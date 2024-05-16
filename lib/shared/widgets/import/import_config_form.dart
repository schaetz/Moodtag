import 'package:flutter/material.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ImportConfigForm<C extends AbstractImportConfig, O extends AbstractImportOption> extends StatefulWidget {
  final String headlineCaption;
  final String sendButtonCaption;
  final Map<O, String> optionsWithCaption;
  final List<TagCategoryData> tagCategories;
  final List<Tag> tags;
  final C initialConfig;
  final Function(Map<O, bool>) onChangeSelection;

  const ImportConfigForm({
    Key? key,
    required this.headlineCaption,
    required this.sendButtonCaption,
    required this.optionsWithCaption,
    required this.tagCategories,
    required this.tags,
    required this.initialConfig,
    required this.onChangeSelection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImportConfigFormState<C, O>();
}

class _ImportConfigFormState<C extends AbstractImportConfig, O extends AbstractImportOption>
    extends State<ImportConfigForm<C, O>> {
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  final TextEditingController tagCategoryController = TextEditingController();
  final TextEditingController defaultTagController = TextEditingController();

  late final Map<O, bool> _selectionsState;
  TagCategoryData? selectedTagCategory;
  Tag? selectedInitialTag;

  @override
  void initState() {
    super.initState();
    _initializeSelectionsState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
              child: Text(this.widget.headlineCaption, style: headlineStyle),
            )),
        ..._buildCheckboxes(),
        Padding(padding: const EdgeInsets.all(16), child: _buildTagCategoryDropdown()),
        Padding(padding: const EdgeInsets.all(16), child: _buildInitialTagDropdown())
      ],
    );
  }

  List<Widget> _buildCheckboxes() {
    return this
        .widget
        .optionsWithCaption
        .entries
        .map((keyAndCaption) => CheckboxListTile(
              title: Text(keyAndCaption.value),
              value: _selectionsState[keyAndCaption.key],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectionsState[keyAndCaption.key] = newValue;
                  });
                  widget.onChangeSelection(_selectionsState);
                }
              },
            ))
        .toList();
  }

  Widget _buildTagCategoryDropdown() {
    return DropdownMenu<TagCategoryData>(
      controller: tagCategoryController,
      enableFilter: true,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.search),
      label: const Text('Tag category for all tags'),
      width: 260,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: (TagCategoryData? category) {
        setState(() {
          selectedTagCategory = category;
        });
      },
      dropdownMenuEntries: widget.tagCategories.map<DropdownMenuEntry<TagCategoryData>>(
        (TagCategoryData tagCategory) {
          return DropdownMenuEntry<TagCategoryData>(
            value: tagCategory,
            label: tagCategory.tagCategory.name,
            leadingIcon: Icon(
              Icons.circle,
              color: Color(tagCategory.tagCategory.color),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildInitialTagDropdown() {
    return DropdownMenu<Tag>(
      controller: defaultTagController,
      enableFilter: true,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.search),
      label: const Text('Initial tag for all artists'),
      width: 260,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: (Tag? tag) {
        setState(() {
          selectedInitialTag = tag;
        });
      },
      dropdownMenuEntries: widget.tags.map<DropdownMenuEntry<Tag>>(
        (Tag tag) {
          return DropdownMenuEntry<Tag>(
            value: tag,
            label: tag.name,
            leadingIcon: Icon(
              Icons.label,
            ),
          );
        },
      ).toList(),
    );
  }

  void _initializeSelectionsState() {
    this._selectionsState = {};
    widget.optionsWithCaption.entries.forEach((keyAndCaption) =>
        this._selectionsState[keyAndCaption.key] = widget.initialConfig.options[keyAndCaption.key] ?? false);
  }
}
