#!/bin/bash

echo "🔍 Vérification des headers X-Frame-Options..."
echo "=============================================="

# URL à tester
URL="https://roue.dinorapp.com"

echo "🌐 Test de: $URL"
echo "📋 Headers de réponse:"

# Récupérer les headers
RESPONSE=$(curl -s -I "$URL" 2>/dev/null)

echo "$RESPONSE"
echo ""

# Vérifier X-Frame-Options
if echo "$RESPONSE" | grep -i "x-frame-options" > /dev/null; then
    XFRAME=$(echo "$RESPONSE" | grep -i "x-frame-options" | cut -d: -f2- | sed 's/^ *//')
    echo "❌ X-Frame-Options trouvé: $XFRAME"
    echo "   -> Ce site bloque l'affichage en iframe"
else
    echo "✅ Aucun X-Frame-Options trouvé"
    echo "   -> Ce site autorise l'affichage en iframe"
fi

# Vérifier Content-Security-Policy
if echo "$RESPONSE" | grep -i "content-security-policy" > /dev/null; then
    CSP=$(echo "$RESPONSE" | grep -i "content-security-policy" | cut -d: -f2- | sed 's/^ *//')
    echo "🔒 Content-Security-Policy: $CSP"
    
    if echo "$CSP" | grep -i "frame-ancestors" > /dev/null; then
        echo "   -> Politique frame-ancestors détectée"
    else
        echo "   -> Aucune restriction frame-ancestors"
    fi
else
    echo "ℹ️  Aucune Content-Security-Policy trouvée"
fi

echo ""
echo "🧪 Test iframe en HTML:"
echo "Vous pouvez tester avec ce code HTML:"
echo "<iframe src=\"$URL\" width=\"800\" height=\"600\"></iframe>"

echo ""
echo "🔄 Pour réactualiser le test après modification .htaccess:"
echo "curl -s -I \"$URL\" | grep -i \"x-frame-options\\|content-security-policy\""

echo ""
echo "📋 Résumé :"
echo "• Sites avec X-Frame-Options: DENY/SAMEORIGIN ne peuvent pas être en iframe"
echo "• Sites sans X-Frame-Options peuvent généralement être en iframe"
echo "• Pour tester dans WebEmbed, utilisez les sites compatibles"

echo ""
echo "🧪 URLs de test recommandées :"
echo "• Compatible iframe: http://localhost:3000/pwa/web-embed?url=https://httpbin.org/"
echo "• Compatible iframe: http://localhost:3000/pwa/web-embed?url=https://example.com" 