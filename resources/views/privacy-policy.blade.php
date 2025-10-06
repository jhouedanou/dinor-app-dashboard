<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Politique de Confidentialité - {{ config('app.name') }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; margin: 0; padding: 0; background: #f8fafc; color: #0f172a; }
        .container { max-width: 960px; margin: 0 auto; padding: 3rem 1.5rem; }
        h1 { font-size: 2.5rem; margin-bottom: 1rem; }
        h2 { font-size: 1.5rem; margin-top: 2rem; margin-bottom: 0.75rem; }
        p, li { line-height: 1.7; font-size: 1rem; }
        ul { padding-left: 1.5rem; }
        a { color: #0ea5e9; text-decoration: underline; }
        .meta { color: #475569; margin-bottom: 1.5rem; }
        @media (max-width: 640px) {
            h1 { font-size: 2rem; }
            h2 { font-size: 1.25rem; }
        }
    </style>
</head>
<body>
    <main class="container">
        <h1>Politique de Confidentialité</h1>
        <p class="meta">Dernière mise à jour : {{ now()->format('d/m/Y') }}</p>

        <p>Cette politique de confidentialité décrit comment « {{ config('app.name') }} » collecte, utilise et protège les données personnelles collectées via notre tableau de bord et nos applications mobiles associées.</p>

        <h2>1. Responsable du Traitement</h2>
        <p>Le responsable du traitement est l'équipe Dinor. Pour toute question concernant cette politique, vous pouvez nous contacter à l'adresse suivante : <a href="mailto:jeanluc@bigfiveabidjan.com">jeanluc@bigfiveabidjan.com</a>.</p>

        <h2>2. Données Collectées</h2>
        <p>Nous collectons des informations liées à l'utilisation de la plateforme, notamment :</p>
        <ul>
            <li>Données de compte (nom, email, rôle administrateur) pour l'accès au tableau de bord.</li>
            <li>Données opérationnelles liées aux recettes, tournois et interactions sur les applications Dinor.</li>
            <li>Données techniques (logs, adresses IP, identifiants de session) pour assurer la sécurité et la maintenance.</li>
        </ul>

        <h2>3. Finalités du Traitement</h2>
        <p>Les données sont utilisées pour :</p>
        <ul>
            <li>Gérer et sécuriser l'accès des administrateurs au tableau de bord.</li>
            <li>Assurer le suivi des opérations (contenu, tournois, notifications).</li>
            <li>Améliorer l'expérience utilisateur via des analyses techniques ou statistiques.</li>
            <li>Respecter les obligations légales et réglementaires applicables.</li>
        </ul>

        <h2>4. Base Légale</h2>
        <p>Les traitements réalisés reposent sur l'exécution du contrat d'utilisation de la plateforme, l'intérêt légitime pour la maintenance et la sécurité, ainsi que le respect des obligations légales.</p>

        <h2>5. Partage des Données</h2>
        <p>Les données ne sont partagées qu'avec des prestataires strictement nécessaires au fonctionnement du service (hébergement, analytics, messagerie) et situés dans l'Union Européenne ou disposant de garanties adéquates.</p>

        <h2>6. Durée de Conservation</h2>
        <p>Les données sont conservées pendant la durée de l'utilisation de la plateforme et archivées pendant la durée légale nécessaire à la gestion des responsabilités. Les journaux techniques sont conservés pour une durée maximale de 12 mois.</p>

        <h2>7. Droits des Utilisateurs</h2>
        <p>Conformément à la réglementation applicable (RGPD, loi Informatique et Libertés), vous disposez des droits suivants :</p>
        <ul>
            <li>Droit d'accès, de rectification et d'effacement des données personnelles.</li>
            <li>Droit d'opposition et de limitation du traitement.</li>
            <li>Droit à la portabilité des données dans la mesure applicable.</li>
            <li>Droit d'introduire une réclamation auprès de la CNIL.</li>
        </ul>
        <p>Pour exercer vos droits, veuillez nous contacter à <a href="mailto:jeanluc@bigfiveabidjan.com">jeanluc@bigfiveabidjan.com</a>.</p>

        <h2>8. Sécurité</h2>
        <p>Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données contre la perte, l'accès non autorisé ou la divulgation. Cela inclut des contrôles d'accès, le chiffrement et des audits réguliers.</p>

        <h2>9. Transferts Internationaux</h2>
        <p>Lorsque des données sont transférées hors de l'Espace Économique Européen, nous nous assurons que des garanties appropriées sont en place (clauses contractuelles types, certification ou décision d'adéquation).</p>

        <h2>10. Mise à Jour</h2>
        <p>Cette politique peut être mise à jour pour refléter les évolutions légales ou fonctionnelles de la plateforme. Nous vous informerons des changements substantiels par les canaux de communication habituels.</p>
    </main>
</body>
</html>
