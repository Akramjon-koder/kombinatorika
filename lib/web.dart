import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'src/helpers/shared_service.dart';
import 'src/network/progress_repository.dart';
import 'src/router/web_router.dart';
import 'src/theme/apptheme.dart';

/// Root of the web app: creates repositories once, provides them to the tree
/// and builds the go_router (see `src/router/web_router.dart`).
class WebApp extends StatefulWidget {
  final SharedPrefService pref;

  const WebApp({super.key, required this.pref});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late final ProgressRepository progressRepository;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    progressRepository = ProgressRepository(widget.pref);
    router = buildWebRouter(progressRepository);
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: progressRepository),
      ],
      child: MaterialApp.router(
        title: 'Kombinatorika shahri',
        debugShowCheckedModeBanner: false,
        theme: theme.materialTheme,
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
