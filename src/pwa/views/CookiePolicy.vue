<template>
  <div class="legal-page">
    <div class="legal-content">
      <header class="legal-header">
        <h1 class="legal-title">Politique des Cookies</h1>
        <p class="legal-date">Dernière mise à jour : {{ lastUpdated }}</p>
      </header>

      <div class="legal-body">
        <section class="legal-section">
          <h2>1. Qu'est-ce qu'un cookie ?</h2>
          <p>
            Un cookie est un petit fichier texte stocké sur votre appareil (ordinateur, tablette, smartphone) 
            lors de votre visite sur notre Application Dinor. Les cookies permettent à l'Application de reconnaître 
            votre appareil et de stocker certaines informations sur vos préférences ou actions passées.
          </p>
          <p>
            Cette politique explique comment et pourquoi nous utilisons des cookies, ainsi que les choix 
            qui s'offrent à vous pour les contrôler.
          </p>
        </section>

        <section class="legal-section">
          <h2>2. Types de cookies utilisés</h2>
          
          <h3>2.1 Cookies strictement nécessaires</h3>
          <p>
            Ces cookies sont indispensables au fonctionnement de l'Application. Ils vous permettent de naviguer 
            et d'utiliser les fonctionnalités de base comme l'authentification et la sécurité.
          </p>
          <div class="cookie-table">
            <table>
              <thead>
                <tr>
                  <th>Cookie</th>
                  <th>Finalité</th>
                  <th>Durée</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>auth_token</td>
                  <td>Maintien de la session utilisateur</td>
                  <td>Session</td>
                </tr>
                <tr>
                  <td>csrf_token</td>
                  <td>Protection contre les attaques CSRF</td>
                  <td>Session</td>
                </tr>
                <tr>
                  <td>lang</td>
                  <td>Langue préférée de l'utilisateur</td>
                  <td>1 an</td>
                </tr>
              </tbody>
            </table>
          </div>

          <h3>2.2 Cookies de préférences</h3>
          <p>
            Ces cookies permettent à l'Application de se souvenir de vos choix (comme votre nom d'utilisateur, 
            langue, région) et de vous fournir des fonctionnalités améliorées et personnalisées.
          </p>
          <div class="cookie-table">
            <table>
              <thead>
                <tr>
                  <th>Cookie</th>
                  <th>Finalité</th>
                  <th>Durée</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>user_preferences</td>
                  <td>Préférences d'affichage</td>
                  <td>6 mois</td>
                </tr>
                <tr>
                  <td>theme</td>
                  <td>Thème sombre/clair</td>
                  <td>1 an</td>
                </tr>
                <tr>
                  <td>favorites</td>
                  <td>Recettes favorites (utilisateurs non connectés)</td>
                  <td>3 mois</td>
                </tr>
              </tbody>
            </table>
          </div>

          <h3>2.3 Cookies statistiques</h3>
          <p>
            Ces cookies nous aident à comprendre comment les visiteurs interagissent avec l'Application 
            en collectant et rapportant des informations de manière anonyme.
          </p>
          <div class="cookie-table">
            <table>
              <thead>
                <tr>
                  <th>Cookie</th>
                  <th>Finalité</th>
                  <th>Durée</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>_ga</td>
                  <td>Google Analytics - Identification des utilisateurs</td>
                  <td>2 ans</td>
                </tr>
                <tr>
                  <td>_ga_*</td>
                  <td>Google Analytics 4 - État de la session</td>
                  <td>2 ans</td>
                </tr>
                <tr>
                  <td>analytics_session</td>
                  <td>Suivi de la session pour les statistiques</td>
                  <td>30 minutes</td>
                </tr>
              </tbody>
            </table>
          </div>

          <h3>2.4 Cookies de marketing (optionnels)</h3>
          <p>
            Ces cookies sont utilisés pour afficher des publicités pertinentes et mesurer l'efficacité 
            de nos campagnes publicitaires. Ils nécessitent votre consentement explicite.
          </p>
          <div class="cookie-table">
            <table>
              <thead>
                <tr>
                  <th>Cookie</th>
                  <th>Finalité</th>
                  <th>Durée</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>marketing_consent</td>
                  <td>Consentement aux cookies marketing</td>
                  <td>1 an</td>
                </tr>
                <tr>
                  <td>ad_personalization</td>
                  <td>Personnalisation des publicités</td>
                  <td>90 jours</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section class="legal-section">
          <h2>3. Technologies similaires</h2>
          
          <h3>3.1 Local Storage</h3>
          <p>
            Nous utilisons le stockage local de votre navigateur pour sauvegarder vos préférences 
            et améliorer les performances de l'Application. Ces données restent sur votre appareil.
          </p>

          <h3>3.2 Session Storage</h3>
          <p>
            Le stockage de session est utilisé pour maintenir temporairement des informations 
            pendant votre visite. Ces données sont supprimées à la fermeture de votre navigateur.
          </p>

          <h3>3.3 Web Beacons (pixels de suivi)</h3>
          <p>
            Nous pouvons utiliser des pixels invisibles pour mesurer l'engagement et analyser 
            le trafic, notamment dans nos communications par email.
          </p>
        </section>

        <section class="legal-section">
          <h2>4. Cookies tiers</h2>
          
          <h3>4.1 Services d'analyse</h3>
          <p><strong>Google Analytics</strong></p>
          <p>
            Nous utilisons Google Analytics pour analyser l'utilisation de notre Application. 
            Google peut utiliser ces données conformément à sa propre politique de confidentialité.
          </p>
          <p>
            Politique de Google : 
            <a href="https://policies.google.com/privacy" class="legal-link" target="_blank" rel="noopener">
              https://policies.google.com/privacy
            </a>
          </p>

          <h3>4.2 Réseaux sociaux</h3>
          <p>
            Lorsque vous partagez du contenu sur les réseaux sociaux depuis notre Application, 
            ces plateformes peuvent placer leurs propres cookies sur votre appareil.
          </p>

          <h3>4.3 Services de cartographie</h3>
          <p>
            Pour afficher les lieux d'événements, nous pouvons utiliser des services de cartographie 
            qui placent leurs propres cookies.
          </p>
        </section>

        <section class="legal-section">
          <h2>5. Durée de conservation</h2>
          <p>
            La durée de conservation des cookies varie selon leur type et leur finalité :
          </p>
          <ul>
            <li><strong>Cookies de session :</strong> supprimés à la fermeture du navigateur</li>
            <li><strong>Cookies persistants :</strong> conservés selon la durée spécifiée dans le tableau ci-dessus</li>
            <li><strong>Cookies tiers :</strong> durée définie par le fournisseur tiers</li>
          </ul>
          <p>
            Vous pouvez supprimer les cookies à tout moment via les paramètres de votre navigateur.
          </p>
        </section>

        <section class="legal-section">
          <h2>6. Base légale</h2>
          <p>Nous utilisons les cookies sur les bases légales suivantes :</p>
          <ul>
            <li>
              <strong>Consentement :</strong> pour les cookies non essentiels (analytiques, marketing)
            </li>
            <li>
              <strong>Intérêt légitime :</strong> pour les cookies nécessaires au fonctionnement du service
            </li>
            <li>
              <strong>Exécution du contrat :</strong> pour les cookies d'authentification et de session
            </li>
          </ul>
        </section>

        <section class="legal-section">
          <h2>7. Gestion de vos préférences</h2>
          
          <h3>7.1 Centre de préférences</h3>
          <p>
            Vous pouvez gérer vos préférences de cookies directement dans l'Application 
            via le centre de préférences accessible dans les paramètres de votre compte.
          </p>

          <h3>7.2 Paramètres du navigateur</h3>
          <p>
            Vous pouvez également contrôler les cookies via les paramètres de votre navigateur :
          </p>
          <ul>
            <li><strong>Chrome :</strong> Paramètres > Confidentialité et sécurité > Cookies</li>
            <li><strong>Firefox :</strong> Paramètres > Vie privée et sécurité > Cookies</li>
            <li><strong>Safari :</strong> Préférences > Confidentialité > Cookies</li>
            <li><strong>Edge :</strong> Paramètres > Cookies et autorisations de site</li>
          </ul>

          <h3>7.3 Refus des cookies</h3>
          <p>
            <strong>Attention :</strong> Si vous refusez ou supprimez les cookies nécessaires, 
            certaines fonctionnalités de l'Application peuvent ne plus fonctionner correctement.
          </p>
        </section>

        <section class="legal-section">
          <h2>8. Outils de désactivation</h2>
          
          <h3>8.1 Google Analytics</h3>
          <p>
            Vous pouvez désactiver Google Analytics en installant le module complémentaire de navigateur :
            <a href="https://tools.google.com/dlpage/gaoptout" class="legal-link" target="_blank" rel="noopener">
              https://tools.google.com/dlpage/gaoptout
            </a>
          </p>

          <h3>8.2 Publicité comportementale</h3>
          <p>
            Pour vous désinscrire de la publicité comportementale, visitez :
            <a href="http://www.youronlinechoices.eu/" class="legal-link" target="_blank" rel="noopener">
              www.youronlinechoices.eu
            </a>
          </p>
        </section>

        <section class="legal-section">
          <h2>9. Mise à jour de la politique</h2>
          <p>
            Cette politique des cookies peut être mise à jour périodiquement pour refléter 
            les changements dans notre utilisation des cookies ou pour d'autres raisons opérationnelles, 
            légales ou réglementaires.
          </p>
          <p>
            Les modifications importantes vous seront notifiées via l'Application ou par email.
          </p>
        </section>

        <section class="legal-section">
          <h2>10. Contact</h2>
          <p>
            Pour toute question concernant notre utilisation des cookies, contactez-nous :
          </p>
          <p>
            Email : <a href="mailto:privacy@dinor.app" class="legal-link">privacy@dinor.app</a><br>
            DPO : <a href="mailto:dpo@dinor.app" class="legal-link">dpo@dinor.app</a>
          </p>
          <p>
            Vous pouvez également exercer vos droits concernant les cookies dans les paramètres 
            de votre compte ou en nous contactant directement.
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
  name: 'CookiePolicy',
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

/* Cookie Tables */
.cookie-table {
  margin: 16px 0;
  overflow-x: auto;
  border-radius: 8px;
  border: 1px solid #E2E8F0;
}

.cookie-table table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.cookie-table th {
  background: #F8F9FA;
  padding: 12px 8px;
  text-align: left;
  font-weight: 600;
  color: #2D3748;
  border-bottom: 1px solid #E2E8F0;
}

.cookie-table td {
  padding: 12px 8px;
  border-bottom: 1px solid #F1F5F9;
  color: #4A5568;
  vertical-align: top;
}

.cookie-table tr:last-child td {
  border-bottom: none;
}

.cookie-table tr:nth-child(even) {
  background: #FAFAFA;
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
  
  .cookie-table th,
  .cookie-table td {
    padding: 8px 6px;
    font-size: 12px;
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
  
  .cookie-table {
    font-size: 11px;
  }
  
  .cookie-table th,
  .cookie-table td {
    padding: 6px 4px;
  }
}
</style>