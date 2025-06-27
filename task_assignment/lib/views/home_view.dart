import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/task_view_model.dart';
import '../models/task_model.dart';
import '../widgets/task_tile.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int _currentPage = 1;
  final int _pageSize = 10;
  List<TaskModel> _paginatedTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final allTasks = taskVM.cachedTasks;

    final nextPage = _currentPage + 1;
    final startIndex = (_currentPage) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < allTasks.length) {
      setState(() {
        _currentPage = nextPage;
        _paginatedTasks.addAll(
          allTasks.sublist(startIndex, endIndex.clamp(0, allTasks.length)),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    _paginatedTasks = tasks.take(_pageSize).toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: _paginatedTasks.length,
      itemBuilder: (_, i) => TaskTile(
        task: _paginatedTasks[i],
        onTap: () => context.push('/task/${_paginatedTasks[i].id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final taskVM = Provider.of<TaskViewModel>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your Tasks'),
              Tab(text: 'Assigned to You'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authVM.signOut(),
            ),
          ],
        ),
        body: StreamBuilder<List<TaskModel>>(
          stream: taskVM.taskStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allTasks = snapshot.data ?? [];
            taskVM.cachedTasks = allTasks; // Store in VM for pagination

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(allTasks), // Your Tasks (TODO: filter by owner)
                _buildTaskList(
                  allTasks,
                ), // Assigned to you (TODO: filter by sharedWith)
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/task'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
