// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

class SplitOrTabs extends StatefulWidget {
  const SplitOrTabs({required this.tabs, required this.children, super.key});
  final List<Widget> tabs;
  final List<Widget> children;

  @override
  State<SplitOrTabs> createState() => _SplitOrTabsState();
}

class _SplitOrTabsState extends State<SplitOrTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.of(context).size.width > 600
      ? SplitView(
          viewMode: SplitViewMode.Horizontal,
          gripColor: Colors.transparent,
          indicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            color: Colors.grey,
          ),
          gripColorActive: Colors.transparent,
          activeIndicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            isActive: true,
            color: Colors.black,
          ),
          children: widget.children,
        )
      : Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: widget.tabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.children,
              ),
            ),
          ],
        );
}
