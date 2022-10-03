// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use, avoid_unnecessary_containers, unused_element, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:taskwarrior/drawer/filter_drawer.dart';
import 'package:taskwarrior/model/storage/storage_widget.dart';
import 'package:taskwarrior/routes/pageroute.dart';
import 'package:taskwarrior/widgets/addTask.dart';
import 'package:taskwarrior/widgets/buildTasks.dart';
import 'package:taskwarrior/widgets/pallete.dart';
import 'package:taskwarrior/widgets/tag_filter.dart';
import 'package:taskwarrior/widgets/taskw.dart';

class Filters {
  const Filters({
    required this.pendingFilter,
    required this.togglePendingFilter,
    required this.tagFilters,
    required this.projects,
    required this.projectFilter,
    required this.toggleProjectFilter,
  });

  final bool pendingFilter;
  final void Function() togglePendingFilter;
  final TagFilters tagFilters;
  final dynamic projects;
  final String projectFilter;
  final void Function(String) toggleProjectFilter;
}

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static bool _darkmode = false;
  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);
    var taskData = storageWidget.tasks;
    

    var pendingFilter = storageWidget.pendingFilter;
    var pendingTags = storageWidget.pendingTags;

    var selectedTagsMap = {
      for (var tag in storageWidget.selectedTags) tag.substring(1): tag,
    };

    var keys = (pendingTags.keys.toSet()..addAll(selectedTagsMap.keys)).toList()
      ..sort();

    var tags = {
      for (var tag in keys)
        tag: TagFilterMetadata(
          display:
              '${selectedTagsMap[tag] ?? tag} ${pendingTags[tag]?.frequency ?? 0}',
          selected: selectedTagsMap.containsKey(tag),
        ),
    };

    var tagFilters = TagFilters(
      tagUnion: storageWidget.tagUnion,
      toggleTagUnion: storageWidget.toggleTagUnion,
      tags: tags,
      toggleTagFilter: storageWidget.toggleTagFilter,
    );
    var filters = Filters(
      pendingFilter: pendingFilter,
      togglePendingFilter: storageWidget.togglePendingFilter,
      projects: storageWidget.projects,
      projectFilter: storageWidget.projectFilter,
      toggleProjectFilter: storageWidget.toggleProjectFilter,
      tagFilters: tagFilters,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kToDark.shade200,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.person_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, PageRoutes.profile);
            },
          ),
        ),
        title: Text('Home Page', style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            child: _darkmode?const Icon(
                Icons.light_mode,
                color: Color.fromARGB(255, 216, 196, 15),
                size: 25,
              ): const Icon(
                Icons.dark_mode,
                color: Colors.white,
                size: 25,
              ),
              onTap: (){
                if(_darkmode){
                  _darkmode = false;
                }
                else{
                  _darkmode = true;
                }
                setState(() {});
              },),

          IconButton(
            icon: (storageWidget.searchVisible)
                ? const Icon(Icons.cancel, color: Colors.white)
                : const Icon(Icons.search, color: Colors.white),
            onPressed: storageWidget.toggleSearch,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => storageWidget.synchronize(context),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Container(
        color: _darkmode?Palette.kToDark.shade200:Colors.white,
        child: Column(
          children: <Widget>[
            if (storageWidget.searchVisible)
              Card(
                child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    storageWidget.search(value);
                  },
                  controller: storageWidget.searchController,
                ),
              ),
            Expanded(
              child: Scrollbar(
                child: TasksBuilder(
                  darkmode: _darkmode,
                  taskData: taskData,
                  pendingFilter: pendingFilter,
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: FilterDrawer(filters),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddTaskBottomSheet(),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
