<template>
  <div class="legal-page">
    <div class="legal-content">
      <header class="legal-header">
        <h1 class="legal-title">Conditions Générales d'Utilisation</h1>
        <p class="legal-date">Dernière mise à jour : {{ lastUpdated }}</p>
      </header>

      <div class="legal-body">
        <section class="legal-section">
          <h2>1. Objet</h2>
          <p>
            Les présentes Conditions Générales d'Utilisation (ci-après "CGU") régissent l'utilisation de l'application mobile et web 
            Dinor (ci-après "l'Application"), proposée par Dinor (ci-après "nous", "notre" ou "la Société").
          </p>
          <p>
            L'Application a pour objet de proposer des recettes de cuisine, des astuces culinaires, des informations sur des événements 
            gastronomiques et du contenu vidéo lié à la cuisine et à la gastronomie.
          </p>
        </section>

        <section class="legal-section">
          <h2>2. Acceptation des conditions</h2>
          <p>
            En accédant à l'Application et en l'utilisant, vous acceptez d'être lié par les présentes CGU. 
            Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'Application.
          </p>
          <p>
            Nous nous réservons le droit de modifier ces CGU à tout moment. Les modifications prendront effet 
            dès leur publication sur l'Application. Il vous incombe de consulter régulièrement ces CGU.
          </p>
        </section>

        <section class="legal-section">
          <h2>3. Description du service</h2>
          <p>L'Application Dinor propose les services suivants :</p>
          <ul>
            <li>Consultation de recettes de cuisine avec instructions détaillées</li>
            <li>Accès à des astuces et conseils culinaires</li>
            <li>Informations sur des événements gastronomiques</li>
            <li>Contenu vidéo éducatif et divertissant (Dinor TV)</li>
            <li>Fonctionnalités de favoris et de partage</li>
            <li>Système de commentaires et d'interactions</li>
          </ul>
        </section>

        <section class="legal-section">
          <h2>4. Inscription et compte utilisateur</h2>
          <p>
            Pour accéder à certaines fonctionnalités de l'Application, vous devez créer un compte utilisateur. 
            Vous vous engagez à fournir des informations exactes, complètes et à jour.
          </p>
          <p>
            Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toutes les activités 
            qui se produisent sous votre compte. Vous devez nous informer immédiatement de toute utilisation non autorisée de votre compte.
          </p>
        </section>

        <section class="legal-section">
          <h2>5. Utilisation de l'Application</h2>
          <h3>5.1 Utilisation autorisée</h3>
          <p>Vous pouvez utiliser l'Application uniquement :</p>
          <ul>
            <li>À des fins personnelles et non commerciales</li>
            <li>Conformément aux présentes CGU et à la législation applicable</li>
            <li>En respectant les droits des autres utilisateurs</li>
          </ul>

          <h3>5.2 Utilisation interdite</h3>
          <p>Il vous est strictement interdit de :</p>
          <ul>
            <li>Utiliser l'Application à des fins illégales ou non autorisées</li>
            <li>Publier du contenu offensant, diffamatoire ou inapproprié</li>
            <li>Tenter de compromettre la sécurité de l'Application</li>
            <li>Reproduire, distribuer ou modifier le contenu sans autorisation</li>
            <li>Utiliser des robots, scripts ou autres moyens automatisés</li>
          </ul>
        </section>

        <section class="legal-section">
          <h2>6. Contenu utilisateur</h2>
          <p>
            En publiant du contenu sur l'Application (commentaires, avis, etc.), vous nous accordez une licence 
            mondiale, gratuite et non exclusive d'utiliser, reproduire, modifier et distribuer ce contenu.
          </p>
          <p>
            Vous garantissez que votre contenu ne viole aucun droit de tiers et respecte les présentes CGU. 
            Nous nous réservons le droit de supprimer tout contenu inapproprié.
          </p>
        </section>

        <section class="legal-section">
          <h2>7. Propriété intellectuelle</h2>
          <p>
            L'Application et son contenu (recettes, textes, images, vidéos, logos, etc.) sont protégés par les droits 
            d'auteur et autres droits de propriété intellectuelle. Tous les droits sont réservés.
          </p>
          <p>
            Aucune licence ou droit d'utilisation commerciale n'est accordé, sauf autorisation expresse et écrite de notre part.
          </p>
        </section>

        <section class="legal-section">
          <h2>8. Responsabilité</h2>
          <p>
            L'Application est fournie "en l'état" sans aucune garantie. Nous nous efforçons de maintenir l'Application 
            accessible et fonctionnelle, mais ne pouvons garantir un service ininterrompu.
          </p>
          <p>
            Nous ne saurions être tenus responsables des dommages directs ou indirects résultant de l'utilisation 
            ou de l'impossibilité d'utiliser l'Application.
          </p>
          <p>
            Les recettes et conseils culinaires sont fournis à titre informatif. Nous ne saurions être responsables 
            d'allergies, intoxications ou autres problèmes de santé liés à l'utilisation de nos recettes.
          </p>
        </section>

        <section class="legal-section">
          <h2>9. Protection des données personnelles</h2>
          <p>
            Le traitement de vos données personnelles est régi par notre 
            <router-link to="/privacy" class="legal-link">Politique de Confidentialité</router-link>, 
            qui fait partie intégrante des présentes CGU.
          </p>
        </section>

        <section class="legal-section">
          <h2>10. Cookies</h2>
          <p>
            L'utilisation des cookies sur notre Application est décrite dans notre 
            <router-link to="/cookies" class="legal-link">Politique des Cookies</router-link>.
          </p>
        </section>

        <section class="legal-section">
          <h2>11. Suspension et résiliation</h2>
          <p>
            Nous nous réservons le droit de suspendre ou de résilier votre accès à l'Application en cas de violation 
            des présentes CGU, sans préavis et sans indemnité.
          </p>
          <p>
            Vous pouvez supprimer votre compte à tout moment depuis les paramètres de votre profil ou en nous contactant.
          </p>
        </section>

        <section class="legal-section">
          <h2>12. Droit applicable et juridiction</h2>
          <p>
            Les présentes CGU sont régies par le droit français. En cas de litige, les tribunaux français seront seuls compétents.
          </p>
        </section>

        <section class="legal-section">
          <h2>13. Contact</h2>
          <p>
            Pour toute question concernant ces CGU, vous pouvez nous contacter à l'adresse : 
            <a href="mailto:legal@dinor.app" class="legal-link">legal@dinor.app</a>
          </p>
        </section>
      </div>

      <footer class="legal-footer">
        <p>© {{ currentYear }} Dinor. Tous droits réservés.</p>
      </footer>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'TermsOfService',
  setup() {
    const lastUpdated = computed(() => {
      return new Date('2024-01-01').toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    })

    const currentYear = computed(() => {
      return new Date().getFullYear()
    })

    return {
      lastUpdated,
      currentYear
    }
  }
}
</script>

<style scoped>
.legal-page {
  min-height: 100vh;
  background: #FFFFFF;
  padding: 16px;
  padding-bottom: 100px; /* Space for bottom nav */
  font-family: 'Roboto', sans-serif;
}

.legal-content {
  max-width: 800px;
  margin: 0 auto;
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.legal-header {
  background: linear-gradient(135deg, #E53E3E 0%, #C53030 100%);
  color: #FFFFFF;
  padding: 32px 24px;
  text-align: center;
}

.legal-title {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 700;
  font-family: 'Open Sans', sans-serif;
}

.legal-date {
  margin: 0;
  font-size: 14px;
  opacity: 0.9;
}

.legal-body {
  padding: 32px 24px;
}

.legal-section {
  margin-bottom: 32px;
}

.legal-section:last-child {
  margin-bottom: 0;
}

.legal-section h2 {
  margin: 0 0 16px 0;
  font-size: 20px;
  font-weight: 600;
  color: #E53E3E;
  font-family: 'Open Sans', sans-serif;
  border-bottom: 2px solid #F4D03F;
  padding-bottom: 8px;
}

.legal-section h3 {
  margin: 24px 0 12px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2D3748;
  font-family: 'Open Sans', sans-serif;
}

.legal-section p {
  margin: 0 0 16px 0;
  font-size: 14px;
  line-height: 1.6;
  color: #4A5568;
}

.legal-section p:last-child {
  margin-bottom: 0;
}

.legal-section ul {
  margin: 0 0 16px 0;
  padding-left: 24px;
}

.legal-section li {
  margin-bottom: 8px;
  font-size: 14px;
  line-height: 1.6;
  color: #4A5568;
}

.legal-link {
  color: #E53E3E;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.legal-link:hover {
  color: #C53030;
  text-decoration: underline;
}

.legal-footer {
  background: #F8F9FA;
  padding: 24px;
  text-align: center;
  border-top: 1px solid #E2E8F0;
}

.legal-footer p {
  margin: 0;
  font-size: 12px;
  color: #4A5568;
}

/* Responsive */
@media (max-width: 768px) {
  .legal-page {
    padding: 12px;
  }
  
  .legal-header {
    padding: 24px 16px;
  }
  
  .legal-title {
    font-size: 24px;
  }
  
  .legal-body {
    padding: 24px 16px;
  }
  
  .legal-section h2 {
    font-size: 18px;
  }
}

@media (max-width: 480px) {
  .legal-page {
    padding: 8px;
  }
  
  .legal-header {
    padding: 20px 12px;
  }
  
  .legal-title {
    font-size: 20px;
  }
  
  .legal-body {
    padding: 20px 12px;
  }
  
  .legal-footer {
    padding: 16px 12px;
  }
}
</style>