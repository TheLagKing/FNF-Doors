#!/bin/bash

# Répertoire de base (modifier si besoin)
BASE_DIR="./assets/songs"

# Qualité de recompression (tu peux mettre -q 5)
QUALITY="-q 4"

# Temp dir
TMP_WAV="/tmp/temp_ogg_recompress.wav"

# Statistiques
total=0
recompressed=0
skipped=0

echo "🔍 Recherche des fichiers à recompresser..."

find "$BASE_DIR" -type f \( -iname "Inst.ogg" -o -iname "Voices.ogg" \) | while read -r ogg_file; do
    ((total++))
    dir=$(dirname "$ogg_file")
    base=$(basename "$ogg_file" .ogg)

    echo "🎵 Traitement : $ogg_file"

    # Décode vers WAV temporaire
    if ! oggdec "$ogg_file" -o "$TMP_WAV"; then
        echo "❌ Échec du décodage, on ignore : $ogg_file"
        ((skipped++))
        continue
    fi

    # Réencode en OGG compressé
    oggenc $QUALITY "$TMP_WAV" -o "$ogg_file.recompressed"
    if [ $? -ne 0 ]; then
        echo "❌ Échec du réencodage, on ignore : $ogg_file"
        ((skipped++))
        rm -f "$ogg_file.recompressed"
        continue
    fi

    # Remplace l'original si tout est ok
    mv "$ogg_file.recompressed" "$ogg_file.recompressed.test.ogg"
    echo "✅ Comprimé avec succès : $ogg_file"
    ((recompressed++))
done

# Nettoyage
rm -f "$TMP_WAV"

echo ""
echo "📊 Résumé :"
echo "  Total trouvé     : $total"
echo "  Recompressés     : $recompressed"
echo "  Ignorés/Échoués  : $skipped"