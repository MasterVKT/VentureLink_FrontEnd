import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:auto_route/auto_route.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (projectProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur : \\n${projectProvider.error!}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => projectProvider.loadProjects(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        if (projectProvider.projects.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Aucun projet disponible')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Liste des Projets')),
          body: RefreshIndicator(
            onRefresh: () => projectProvider.loadProjects(),
            child: ListView.builder(
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.shortDescription),
                  onTap: () {
                    context.router
                        .push(ProjectDetailRoute(projectId: project.id));
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
