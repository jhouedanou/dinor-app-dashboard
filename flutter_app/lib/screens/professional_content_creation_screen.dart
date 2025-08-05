import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../composables/use_auth_handler.dart';
import '../services/api_service.dart';
import '../components/common/auth_modal.dart';

class ProfessionalContentCreationScreen extends ConsumerStatefulWidget {
  const ProfessionalContentCreationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfessionalContentCreationScreen> createState() => _ProfessionalContentCreationScreenState();
}

class _ProfessionalContentCreationScreenState extends ConsumerState<ProfessionalContentCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  
  String _selectedContentType = 'recipe';
  String? _selectedDifficulty;
  List<Map<String, String>> _ingredients = [];
  List<String> _steps = [];
  List<String> _tags = [];
  bool _isLoading = false;
  
  Map<String, String> _contentTypes = {};
  Map<String, String> _difficulties = {};

  @override
  void initState() {
    super.initState();
    _loadContentTypes();
  }

  Future<void> _loadContentTypes() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getProfessionalContentTypes();
      
      if (response['success'] == true) {
        setState(() {
          _contentTypes = Map<String, String>.from(response['data']['content_types'] ?? {});
          _difficulties = Map<String, String>.from(response['data']['difficulties'] ?? {});
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des types: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(useAuthHandlerProvider);
    final authNotifier = ref.read(useAuthHandlerProvider.notifier);
    
    // Vérifier si l'utilisateur est authentifié et professionnel
    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Création de contenu'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Connexion requise',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous devez être connecté pour créer du contenu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _showAuthModal(context),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    if (!authNotifier.isProfessional) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Création de contenu'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Accès professionnel requis',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous devez avoir un compte professionnel pour créer du contenu.\nVotre rôle actuel: ${authState.user?['role'] ?? 'Utilisateur'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer du contenu'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitContent,
            child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Publier',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentTypeSelector(),
              const SizedBox(height: 16),
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              if (_selectedContentType == 'recipe') ...[
                _buildRecipeSpecificSection(),
                const SizedBox(height: 16),
              ],
              _buildAdditionalInfoSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Soumettre le contenu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de contenu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedContentType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Sélectionner le type',
              ),
              items: _contentTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedContentType = value ?? 'recipe';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un type de contenu';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de base',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
              ),
              maxLength: 255,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le titre est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La description est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu détaillé *',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le contenu est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de vidéo (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'https://youtube.com/watch?v=...',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                  return 'Veuillez entrer une URL valide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSpecificSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails recette',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preparationTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Temps préparation (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cookingTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Temps cuisson (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _servingsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de portions',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildIngredientsSection(),
            const SizedBox(height: 16),
            _buildStepsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Ingrédients', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un ingrédient',
            ),
          ],
        ),
        ..._ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: ingredient['name'],
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _ingredients[index]['name'] = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: ingredient['quantity'],
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _ingredients[index]['quantity'] = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: ingredient['unit'],
                      decoration: const InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _ingredients[index]['unit'] = value;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeIngredient(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Étapes', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter une étape',
            ),
          ],
        ),
        ..._steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: step,
                      decoration: const InputDecoration(
                        labelText: 'Instruction',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _steps[index] = value;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeStep(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations complémentaires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_difficulties.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulté',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Non spécifié')),
                  ..._difficulties.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTagsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter un tag',
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _tags.asMap().entries.map((entry) {
            final index = entry.key;
            final tag = entry.value;
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => _removeTag(index),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': '', 'unit': ''});
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String tagText = '';
        return AlertDialog(
          title: const Text('Ajouter un tag'),
          content: TextField(
            onChanged: (value) => tagText = value,
            decoration: const InputDecoration(
              labelText: 'Tag',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (tagText.isNotEmpty) {
                  setState(() {
                    _tags.add(tagText);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  Future<void> _submitContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      final contentData = {
        'content_type': _selectedContentType,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'content': _contentController.text,
        'video_url': _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
        'difficulty': _selectedDifficulty,
        'category': _categoryController.text.isEmpty ? null : _categoryController.text,
        'tags': _tags.isEmpty ? null : _tags,
      };

      // Ajouter les champs spécifiques aux recettes
      if (_selectedContentType == 'recipe') {
        if (_preparationTimeController.text.isNotEmpty) {
          contentData['preparation_time'] = int.tryParse(_preparationTimeController.text);
        }
        if (_cookingTimeController.text.isNotEmpty) {
          contentData['cooking_time'] = int.tryParse(_cookingTimeController.text);
        }
        if (_servingsController.text.isNotEmpty) {
          contentData['servings'] = int.tryParse(_servingsController.text);
        }
        if (_ingredients.isNotEmpty) {
          contentData['ingredients'] = _ingredients.where((ing) => ing['name']!.isNotEmpty).toList();
        }
        if (_steps.isNotEmpty) {
          contentData['steps'] = _steps.where((step) => step.isNotEmpty).map((step) => {'instruction': step}).toList();
        }
      }

      final response = await apiService.createProfessionalContent(contentData);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contenu soumis avec succès! Il sera examiné par les modérateurs.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${response['error'] ?? 'Erreur inconnue'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAuthModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AuthModal(isOpen: true);
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _categoryController.dispose();
    _preparationTimeController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }
}