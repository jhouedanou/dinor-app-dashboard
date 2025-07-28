/**
 * COOKIE_POLICY_SCREEN.DART - ÉCRAN POLITIQUE DES COOKIES
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec contenu scrollable
 * - Typographie claire et lisible
 * - Navigation simple
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Affichage de la politique des cookies
 * - Contenu statique ou dynamique
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Politique des Cookies',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Politique des Cookies',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dernière mise à jour : ${DateTime.now().year}',
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '1. Qu\'est-ce qu\'un cookie ?',
                'Un cookie est un petit fichier texte stocké sur votre appareil lorsque vous visitez un site web ou utilisez une application. Les cookies nous aident à améliorer votre expérience en mémorisant vos préférences et en analysant l\'utilisation de l\'application.',
              ),
              _buildSection(
                '2. Types de cookies que nous utilisons',
                'Nous utilisons différents types de cookies :\n\n• Cookies essentiels : nécessaires au fonctionnement de l\'application\n• Cookies de performance : pour analyser l\'utilisation et améliorer nos services\n• Cookies de fonctionnalité : pour mémoriser vos préférences\n• Cookies de ciblage : pour vous proposer du contenu personnalisé',
              ),
              _buildSection(
                '3. Cookies tiers',
                'Nous pouvons également utiliser des cookies de tiers, tels que Google Analytics, pour analyser l\'utilisation de l\'application et améliorer nos services. Ces tiers ont leurs propres politiques de confidentialité.',
              ),
              _buildSection(
                '4. Gestion des cookies',
                'Vous pouvez contrôler et gérer les cookies via les paramètres de votre navigateur ou de votre appareil. Vous pouvez supprimer les cookies existants et empêcher l\'installation de nouveaux cookies.',
              ),
              _buildSection(
                '5. Impact de la désactivation des cookies',
                'Si vous désactivez certains cookies, certaines fonctionnalités de l\'application peuvent ne pas fonctionner correctement. Les cookies essentiels ne peuvent pas être désactivés car ils sont nécessaires au fonctionnement de l\'application.',
              ),
              _buildSection(
                '6. Cookies de l\'application mobile',
                'Notre application mobile utilise des technologies similaires aux cookies pour collecter des informations sur votre appareil et votre utilisation de l\'application.',
              ),
              _buildSection(
                '7. Mise à jour de cette politique',
                'Nous pouvons mettre à jour cette politique des cookies de temps à autre. Nous vous informerons de tout changement important en publiant la nouvelle politique sur l\'application.',
              ),
              _buildSection(
                '8. Contact',
                'Si vous avez des questions concernant notre utilisation des cookies, veuillez nous contacter à l\'adresse suivante : cookies@dinor.app',
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D03F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En continuant à utiliser l\'application Dinor, vous acceptez notre utilisation des cookies conformément à cette politique.',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: Color(0xFF4A5568),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}