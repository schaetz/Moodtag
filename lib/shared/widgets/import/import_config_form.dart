import 'package:flutter/material.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_state.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/utils/optional.dart';

class ImportConfigForm<C extends AbstractImportConfig, O extends AbstractImportOption, B extends AbstractImportBloc<S>,
    S extends AbstractImportState> extends StatefulWidget {
  final String headlineCaption;
  final String sendButtonCaption;
  final Map<O, String> optionsWithCaption;
  final bool showTagCategoriesDropdown;
  final List<TagCategory>? tagCategories;
  final List<Tag> tags;
  final C initialConfig;
  final Function(Optional<Map<AbstractImportOption, bool>> checkboxSelections, Optional<TagCategory> newTagCategory,
      Optional<BaseTag?> newBaseTag) onChangeImportConfig;
  final Function onPressAddTagButton;

  const ImportConfigForm({
    Key? key,
    required this.headlineCaption,
    required this.sendButtonCaption,
    required this.optionsWithCaption,
    required this.showTagCategoriesDropdown,
    required this.tagCategories,
    required this.tags,
    required this.initialConfig,
    required this.onChangeImportConfig,
    required this.onPressAddTagButton,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImportConfigFormState<C, O, B, S>();
}

class _ImportConfigFormState<C extends AbstractImportConfig, O extends AbstractImportOption,
    B extends AbstractImportBloc<S>, S extends AbstractImportState> extends State<ImportConfigForm<C, O, B, S>> {
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  final TextEditingController tagCategoryController = TextEditingController();
  final TextEditingController initialTagController = TextEditingController();

  late final Map<O, bool> _selectionsState;

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
        widget.showTagCategoriesDropdown
            ? Padding(padding: const EdgeInsets.all(16), child: _buildTagCategoryDropdown())
            : Container(),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [_buildInitialTagDropdown(), SizedBox(width: 16), _buildAddTagButton()]))
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
                  widget.onChangeImportConfig(Optional(_selectionsState), Optional.none(), Optional.none());
                }
              },
            ))
        .toList();
  }

  Widget _buildTagCategoryDropdown() {
    if (widget.tagCategories == null) return Container();

    return DropdownMenu<TagCategory>(
      controller: tagCategoryController,
      enableFilter: false,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.search),
      label: const Text('Tag category for all tags'),
      width: 260,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: (TagCategory? category) =>
          widget.onChangeImportConfig(Optional.none(), Optional(category), Optional.none()),
      dropdownMenuEntries: widget.tagCategories!.map<DropdownMenuEntry<TagCategory>>(
        (TagCategory tagCategory) {
          return DropdownMenuEntry<TagCategory>(
            value: tagCategory,
            label: tagCategory.name,
            leadingIcon: Icon(
              Icons.circle,
              color: Color(tagCategory.color),
            ),
          );
        },
      ).toList(),
      initialSelection: widget.initialConfig.categoryForTags,
    );
  }

  Widget _buildInitialTagDropdown() {
    return DropdownMenu<BaseTag>(
      controller: initialTagController,
      enableFilter: true,
      requestFocusOnTap: true,
      leadingIcon: const Icon(Icons.search),
      label: const Text('Initial tag for all artists'),
      width: 260,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: (BaseTag? tag) => widget.onChangeImportConfig(Optional.none(), Optional.none(), Optional(tag)),
      dropdownMenuEntries: widget.tags.map<DropdownMenuEntry<BaseTag>>(
        (BaseTag tag) {
          return DropdownMenuEntry<BaseTag>(
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

  Widget _buildAddTagButton() {
    return ElevatedButton(
      child: Icon(Icons.new_label),
      onPressed: () => widget.onPressAddTagButton(),
    );
  }

  void _initializeSelectionsState() {
    this._selectionsState = {};
    widget.optionsWithCaption.entries.forEach((keyAndCaption) =>
        this._selectionsState[keyAndCaption.key] = widget.initialConfig.options[keyAndCaption.key] ?? false);
  }
}
