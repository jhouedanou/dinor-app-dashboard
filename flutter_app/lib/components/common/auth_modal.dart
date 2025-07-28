/**
 * AUTH_MODAL.DART - CONVERSION FIDÈLE DE AuthModal.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Modal bottom sheet identique
 * - Formulaires login/register identiques
 * - Validation et messages d'erreur identiques
 * - Animation et transitions identiques
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Logique d'authentification identique
 * - Gestion d'état identique
 * - API calls identiques via AuthStore
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../stores/auth_store.dart';

class AuthModal extends ConsumerStatefulWidget {
  final bool isVisible;
  final String? initialMessage;
  final VoidCallback? onClose;
  final Function(Map<String, dynamic>)? onAuthenticated;

  const AuthModal({
    Key? key,
    required this.isVisible,
    this.initialMessage,
    this.onClose,
    this.onAuthenticated,
  }) : super(key: key);

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal>
    with SingleTickerProviderStateMixin {
  bool _isLoginMode = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Contrôleurs de formulaire
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // État du formulaire
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Animation de slide identique à Vue
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AuthModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // REPRODUCTION EXACTE de handleSubmit() Vue
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    final authStore = ref.read(authStoreProvider.notifier);

    try {
      Map<String, dynamic> result;

      if (_isLoginMode) {
        // Login identique à Vue
        print('🔐 [AuthModal] Tentative de connexion');
        result = await authStore.login({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        });
      } else {
        // Register identique à Vue
        print('🔐 [AuthModal] Tentative d\'inscription');
        result = await authStore.register({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        });
      }

      if (result['success'] == true) {
        print('✅ [AuthModal] Authentification réussie');
        
        // Callback avec utilisateur (identique Vue)
        widget.onAuthenticated?.call(result['user']);
        
        // Fermer le modal
        _closeModal();
        
        // Message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLoginMode
                    ? 'Connexion réussie !'
                    : 'Inscription réussie ! Bienvenue sur Dinor.',
              ),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Erreur côté serveur
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur inconnue';
        });
      }
    } catch (error) {
      print('❌ [AuthModal] Erreur authentification: $error');
      setState(() {
        _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
      });
    }
  }

  void _closeModal() {
    widget.onClose?.call();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      // Clear form
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final authStore = ref.watch(authStoreProvider);

    return GestureDetector(
      onTap: _closeModal,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Empêcher la fermeture en cliquant sur le modal
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * MediaQuery.of(context).size.height),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle du modal
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Contenu du modal
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header avec bouton fermer
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isLoginMode ? 'Connexion' : 'Inscription',
                                        style: const TextStyle(
                                          fontFamily: 'OpenSans',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _closeModal,
                                        icon: const Icon(LucideIcons.x),
                                        color: const Color(0xFF4A5568),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Message initial si fourni
                                  if (widget.initialMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3CD),
                                        border: Border.all(color: const Color(0xFFFFDF7E)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.initialMessage!,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF856404),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Message d'erreur
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8D7DA),
                                        border: Border.all(color: const Color(0xFFF5C6CB)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Color(0xFF721C24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Champs du formulaire
                                  if (!_isLoginMode) ...[
                                    // Nom (inscription seulement)
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nom complet',
                                        hintText: 'Entrez votre nom complet',
                                        prefixIcon: Icon(LucideIcons.user),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Le nom est requis';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Le nom doit contenir au moins 2 caractères';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Entrez votre email',
                                      prefixIcon: Icon(LucideIcons.mail),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'L\'email est requis';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                        return 'Email invalide';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Mot de passe
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      hintText: 'Entrez votre mot de passe',
                                      prefixIcon: const Icon(LucideIcons.lock),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Le mot de passe est requis';
                                      }
                                      if (!_isLoginMode && value.length < 6) {
                                        return 'Le mot de passe doit contenir au moins 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirmation mot de passe (inscription seulement)
                                  if (!_isLoginMode) ...[
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Confirmer le mot de passe',
                                        hintText: 'Confirmez votre mot de passe',
                                        prefixIcon: const Icon(LucideIcons.lock),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                          ),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value != _passwordController.text) {
                                          return 'Les mots de passe ne correspondent pas';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  const SizedBox(height: 8),

                                  // Bouton de soumission
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: authStore.loading ? null : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE53E3E),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: authStore.loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              _isLoginMode ? 'Se connecter' : 'S\'inscrire',
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Lien pour basculer entre login/register
                                  Center(
                                    child: TextButton(
                                      onPressed: _toggleMode,
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            color: Color(0xFF4A5568),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: _isLoginMode
                                                  ? 'Pas encore de compte ? '
                                                  : 'Déjà un compte ? ',
                                            ),
                                            TextSpan(
                                              text: _isLoginMode ? 'S\'inscrire' : 'Se connecter',
                                              style: const TextStyle(
                                                color: Color(0xFF6750A4),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}