/**
 * TERMS_OF_SERVICE_SCREEN.DART - ÉCRAN CONDITIONS GÉNÉRALES
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec contenu scrollable
 * - Typographie claire et lisible
 * - Navigation simple
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Affichage des conditions générales
 * - Contenu statique ou dynamique
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Conditions Générales',
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
                'Conditions Générales d\'Utilisation',
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
                '1. Acceptation des conditions',
                'En utilisant l\'application Dinor, vous acceptez d\'être lié par ces conditions générales d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
              ),
              _buildSection(
                '2. Description du service',
                'Dinor est une application mobile qui propose des recettes de cuisine, des astuces culinaires, des événements gastronomiques et du contenu vidéo lié à la cuisine.',
              ),
              _buildSection(
                '3. Utilisation du service',
                'Vous vous engagez à utiliser l\'application Dinor uniquement à des fins légales et conformes à ces conditions. Vous ne devez pas utiliser le service pour transmettre du contenu illégal, offensant ou nuisible.',
              ),
              _buildSection(
                '4. Compte utilisateur',
                'Pour accéder à certaines fonctionnalités, vous devrez créer un compte. Vous êtes responsable de maintenir la confidentialité de vos informations de connexion et de toutes les activités qui se produisent sous votre compte.',
              ),
              _buildSection(
                '5. Contenu utilisateur',
                'En publiant du contenu sur l\'application, vous accordez à Dinor une licence mondiale, non exclusive, gratuite, pour utiliser, reproduire, adapter, publier, traduire et distribuer ce contenu.',
              ),
              _buildSection(
                '6. Propriété intellectuelle',
                'L\'application Dinor et son contenu original, fonctionnalités et fonctionnalités sont et resteront la propriété exclusive de Dinor et de ses concédants de licence.',
              ),
              _buildSection(
                '7. Limitation de responsabilité',
                'Dans toute la mesure permise par la loi applicable, Dinor ne sera pas responsable des dommages indirects, accessoires, spéciaux, consécutifs ou punitifs, ou de toute perte de profits ou de revenus.',
              ),
              _buildSection(
                '8. Modifications des conditions',
                'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications prendront effet immédiatement après leur publication sur l\'application.',
              ),
              _buildSection(
                '9. Contact',
                'Si vous avez des questions concernant ces conditions générales, veuillez nous contacter à l\'adresse suivante : contact@dinor.app',
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D03F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En utilisant l\'application Dinor, vous confirmez avoir lu, compris et accepté ces conditions générales d\'utilisation.',
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