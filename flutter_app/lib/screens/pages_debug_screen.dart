/**
 * PAGES_DEBUG_SCREEN.DART - ÉCRAN DE DEBUG POUR LES PAGES
 * 
 * FONCTIONNALITÉS :
 * - Affichage des pages récupérées depuis l'API
 * - Boutons de test pour les actions
 * - Debug des erreurs de récupération
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../composables/use_pages.dart';
import '../services/api_service.dart';

class PagesDebugScreen extends ConsumerStatefulWidget {
  const PagesDebugScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PagesDebugScreen> createState() => _PagesDebugScreenState();
}

class _PagesDebugScreenState extends ConsumerState<PagesDebugScreen> {
  bool _isTestingApi = false;
  String? _apiTestResult;

  @override
  void initState() {
    super.initState();
    // Charger les pages au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usePagesProvider.notifier).loadPages(forceRefresh: true);
    });
  }

  Future<void> _testApiDirectly() async {
    setState(() {
      _isTestingApi = true;
      _apiTestResult = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Test de l'endpoint des pages
      final response = await apiService.getMenuPages();
      
      setState(() {
        _apiTestResult = '''
✅ API Test Réussi !

Réponse: ${response.toString()}

Status: ${response['success'] ? 'SUCCESS' : 'FAILED'}
Nombre de pages: ${response['data']?.length ?? 0}

Pages trouvées:
${response['data']?.map((page) => '- ${page['title']} (${page['url']})').join('\n') ?? 'Aucune page'}
''';
      });
    } catch (e) {
      setState(() {
        _apiTestResult = '''
❌ Erreur API Test:

$e

Vérifiez:
1. La connexion internet
2. L'URL de l'API (${ref.read(apiServiceProvider)})
3. Les CORS du serveur
4. Les données dans la base de données
''';
      });
    } finally {
      setState(() {
        _isTestingApi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagesState = ref.watch(usePagesProvider);
    final navigationPages = ref.watch(navigationPagesProvider);
    final hasPages = ref.watch(hasPagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Pages API'),
        backgroundColor: const Color(0xFFF4D03F),
        toolbarHeight: 56,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(usePagesProvider.notifier).refreshPages();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // État des pages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État des Pages',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text('Loading: ${pagesState.isLoading}'),
                    Text('Erreur: ${pagesState.error ?? 'Aucune'}'),
                    Text('Nombre de pages: ${pagesState.pages.length}'),
                    Text('Pages de navigation: ${navigationPages.length}'),
                    Text('A des pages: $hasPages'),
                    Text('Dernière MAJ: ${pagesState.lastUpdated?.toString() ?? 'Jamais'}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test API direct
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test API Direct',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isTestingApi ? null : _testApiDirectly,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                      ),
                      child: _isTestingApi
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Test en cours...'),
                              ],
                            )
                          : const Text('Tester l\'API'),
                    ),
                    if (_apiTestResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _apiTestResult!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Liste des pages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pages Récupérées (${pagesState.pages.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (pagesState.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (pagesState.error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          'Erreur: ${pagesState.error}',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    if (pagesState.pages.isEmpty && !pagesState.isLoading)
                      const Text('Aucune page trouvée'),
                    ...pagesState.pages.map((page) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          page.isExternal ? Icons.open_in_new : Icons.web,
                          color: const Color(0xFFFF6B35),
                        ),
                        title: Text(page.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('URL: ${page.url ?? 'Pas d\'URL'}'),
                            Text('Ordre: ${page.order}'),
                            Text('Publié: ${page.isPublished ? 'Oui' : 'Non'}'),
                            Text('Externe: ${page.isExternal ? 'Oui' : 'Non'}'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: page.url != null ? () {
                          // Ouvrir l'URL en mode debug
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(page.title),
                              content: SelectableText(page.url!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        } : null,
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}