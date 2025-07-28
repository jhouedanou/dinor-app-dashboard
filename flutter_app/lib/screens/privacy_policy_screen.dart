/**
 * PRIVACY_POLICY_SCREEN.DART - ÉCRAN POLITIQUE DE CONFIDENTIALITÉ
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec contenu scrollable
 * - Typographie claire et lisible
 * - Navigation simple
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Affichage de la politique de confidentialité
 * - Contenu statique ou dynamique
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Politique de Confidentialité',
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
                'Politique de Confidentialité',
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
                '1. Collecte des informations',
                'Nous collectons les informations que vous nous fournissez directement, telles que votre nom, adresse e-mail, et les informations de profil que vous choisissez de partager.',
              ),
              _buildSection(
                '2. Utilisation des informations',
                'Nous utilisons les informations collectées pour fournir, maintenir et améliorer nos services, communiquer avec vous, et personnaliser votre expérience utilisateur.',
              ),
              _buildSection(
                '3. Partage des informations',
                'Nous ne vendons, n\'échangeons ni ne louons vos informations personnelles à des tiers. Nous pouvons partager vos informations uniquement dans les cas suivants : avec votre consentement, pour respecter la loi, ou pour protéger nos droits.',
              ),
              _buildSection(
                '4. Sécurité des données',
                'Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos informations personnelles contre l\'accès non autorisé, la modification, la divulgation ou la destruction.',
              ),
              _buildSection(
                '5. Cookies et technologies similaires',
                'Nous utilisons des cookies et des technologies similaires pour améliorer votre expérience, analyser l\'utilisation de l\'application et personnaliser le contenu.',
              ),
              _buildSection(
                '6. Vos droits',
                'Vous avez le droit d\'accéder, de corriger, de supprimer vos informations personnelles et de vous opposer à leur traitement. Vous pouvez exercer ces droits en nous contactant.',
              ),
              _buildSection(
                '7. Conservation des données',
                'Nous conservons vos informations personnelles aussi longtemps que nécessaire pour fournir nos services et respecter nos obligations légales.',
              ),
              _buildSection(
                '8. Modifications de cette politique',
                'Nous pouvons mettre à jour cette politique de confidentialité de temps à autre. Nous vous informerons de tout changement important en publiant la nouvelle politique sur l\'application.',
              ),
              _buildSection(
                '9. Contact',
                'Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter à l\'adresse suivante : privacy@dinor.app',
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D03F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En utilisant l\'application Dinor, vous acceptez les pratiques décrites dans cette politique de confidentialité.',
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