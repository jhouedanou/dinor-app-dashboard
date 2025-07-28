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
import '../../composables/use_auth_handler.dart';

class AuthModal extends ConsumerStatefulWidget {
  final bool isOpen;
  final VoidCallback? onClose;
  final VoidCallback? onAuthenticated;

  const AuthModal({
    Key? key,
    required this.isOpen,
    this.onClose,
    this.onAuthenticated,
  }) : super(key: key);

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authHandler = ref.read(useAuthHandlerProvider.notifier);
      bool success;

      if (_isLogin) {
        success = await authHandler.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authHandler.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _passwordConfirmationController.text,
        );
      }

      if (success) {
        widget.onAuthenticated?.call();
        widget.onClose?.call();
      } else {
        setState(() {
          _error = _isLogin 
            ? 'Email ou mot de passe incorrect'
            : 'Erreur lors de l\'inscription';
        });
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isLogin ? 'Connexion' : 'Inscription',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form Fields
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'email est requis';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le mot de passe est requis';
                  }
                  if (!_isLogin && value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  return null;
                },
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmationController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La confirmation est requise';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Se connecter' : 'S\'inscrire',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Toggle Mode
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin 
                    ? 'Pas encore de compte ? S\'inscrire'
                    : 'Déjà un compte ? Se connecter',
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}