<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Conditions d'utilisation - {{ config('app.name') }}</title>
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
        <h1>Conditions d'utilisation</h1>
        <p class="meta">Dernière mise à jour : {{ now()->format('d/m/Y') }}</p>

        <p>Les présentes conditions encadrent l'utilisation de la plateforme d'administration « {{ config('app.name') }} » ainsi que des services associés. En accédant au tableau de bord, vous acceptez ces conditions sans réserve.</p>

        <h2>1. Objet</h2>
        <p>La plateforme permet de gérer les contenus culinaires, les tournois, les notifications et les données des applications Dinor. Elle est réservée aux membres autorisés de l'équipe Dinor.</p>

        <h2>2. Accès au Service</h2>
        <ul>
            <li>L'accès est soumis à l'utilisation d'identifiants individuels fournis par l'équipe Dinor.</li>
            <li>Chaque utilisateur s'engage à maintenir la confidentialité de ses identifiants.</li>
            <li>Tout accès non autorisé doit être signalé immédiatement à <a href="mailto:jeanluc@bigfiveabidjan.com">jeanluc@bigfiveabidjan.com</a>.</li>
        </ul>

        <h2>3. Obligations des Utilisateurs</h2>
        <ul>
            <li>Utiliser la plateforme conformément aux lois en vigueur et aux politiques internes Dinor.</li>
            <li>Veiller à l'exactitude des données saisies et mises à jour.</li>
            <li>Respecter la confidentialité des informations accessibles via la plateforme.</li>
            <li>Ne pas tenter d'altérer, de contourner ou de nuire aux mesures de sécurité.</li>
        </ul>

        <h2>4. Gestion des Contenus</h2>
        <p>Les contenus publiés via la plateforme (recettes, visuels, événements, notifications) restent la propriété de Dinor. Chaque utilisateur garantit disposer des droits nécessaires pour toute ressource importée.</p>

        <h2>5. Sécurité et Maintenance</h2>
        <p>Nous mettons en œuvre des mesures de sécurité adaptées. Des interruptions temporaires peuvent survenir pour des opérations de maintenance ou d'amélioration. Nous informerons les utilisateurs en cas d'interruption planifiée.</p>

        <h2>6. Responsabilité</h2>
        <ul>
            <li>Dinor ne saurait être tenu responsable des dommages indirects résultant d'une mauvaise utilisation de la plateforme.</li>
            <li>Chaque utilisateur est responsable des actions effectuées avec ses identifiants.</li>
            <li>En cas de violation des conditions, l'accès peut être suspendu ou résilié sans préavis.</li>
        </ul>

        <h2>7. Données Personnelles</h2>
        <p>Le traitement des données personnelles est détaillé dans la <a href="{{ url('/privacy-policy') }}">Politique de Confidentialité</a>. En utilisant la plateforme, vous acceptez ces modalités de traitement.</p>

        <h2>8. Propriété Intellectuelle</h2>
        <p>Tous les éléments de la plateforme (logos, interface, contenus) sont protégés par des droits de propriété intellectuelle. Toute reproduction ou diffusion non autorisée est interdite.</p>

        <h2>9. Durée et Résiliation</h2>
        <p>Les présentes conditions s'appliquent pendant toute la durée d'utilisation de la plateforme. Dinor se réserve le droit de modifier, suspendre ou résilier l'accès à tout moment pour des raisons de sécurité ou de non-respect des conditions.</p>

        <h2>10. Évolutions des Conditions</h2>
        <p>Nous pouvons mettre à jour ces conditions pour refléter l'évolution des services ou de la réglementation. Toute modification significative sera communiquée aux utilisateurs autorisés.</p>

        <h2>11. Droit Applicable</h2>
        <p>Les présentes conditions sont régies par le droit ivoirien, notamment les dispositions du Code civil, du Code du numérique et de toute réglementation applicable aux services numériques en Côte d'Ivoire. Tout litige relatif à leur interprétation ou leur exécution relève de la compétence exclusive des juridictions ivoiriennes.</p>

        <p>Pour toute question, contactez-nous à <a href="mailto:jeanluc@bigfiveabidjan.com">jeanluc@bigfiveabidjan.com</a>.</p>
    </main>
</body>
</html>
