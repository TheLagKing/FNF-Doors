import os
import subprocess
import numpy as np

BASE_DIR = "./assets/songs"
THRESHOLD = 0.96  # seuil d'alerte

def load_audio_as_array(path):
    """Lit un fichier audio avec ffmpeg et retourne un tableau numpy normalisé."""
    cmd = [
        "ffmpeg", "-i", path,
        "-f", "s16le",   # PCM 16-bit little-endian
        "-acodec", "pcm_s16le",
        "-ac", "2",      # stéréo
        "-ar", "48000",  # 48 kHz
        "-"              # sortie vers stdout
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=True)
    audio = np.frombuffer(result.stdout, dtype=np.int16).astype(np.float32)
    audio /= 32768.0  # normalisation [-1.0, 1.0]
    return audio

total = 0
below_threshold = 0

print("🔍 Comparaison des fichiers originaux et recompressés...\n")

for root, _, files in os.walk(BASE_DIR):
    for file in files:
        if file.lower() in ("inst.ogg", "voices.ogg"):
            original_path = os.path.join(root, file)
            recompressed_path = original_path + ".recompressed.test.ogg"

            if not os.path.exists(recompressed_path):
                print(f"⚠️  Pas trouvé : {recompressed_path}")
                continue

            total += 1

            try:
                a = load_audio_as_array(original_path)
                b = load_audio_as_array(recompressed_path)

                # Aligner longueurs
                min_len = min(len(a), len(b))
                a = a[:min_len]
                b = b[:min_len]

                corr = np.corrcoef(a, b)[0, 1]

                if corr < THRESHOLD:
                    print(f"❌ {original_path} → Corrélation {corr:.5f} (sous le seuil {THRESHOLD})")
                    below_threshold += 1
                else:
                    print(f"✅ {original_path} → Corrélation {corr:.5f}")

            except subprocess.CalledProcessError:
                print(f"⚠️ Erreur ffmpeg avec {original_path}")

print("\n📊 Résumé :")
print(f"  Total comparés      : {total}")
print(f"  Sous le seuil       : {below_threshold}")
print(f"  Seuil utilisé       : {THRESHOLD}")
