import subprocess
import os
import shutil

BASE_DIR = "./assets/songs"
QUALITY = "4"

total = 0
recompressed = 0
skipped = 0

print("🔍 Searching for files to recompress...")

for root, _, files in os.walk(BASE_DIR):
    for file in files:
        if file.lower() in ("inst.ogg", "voices.ogg"):
            total += 1
            ogg_path = os.path.join(root, file)
            temp_path = ogg_path + ".compressed.ogg"

            print(f"🎵 Processing: {ogg_path}")

            try:
                subprocess.run([
                    "ffmpeg",
                    "-y",
                    "-i", ogg_path,
                    "-c:a", "libvorbis",
                    "-qscale:a", QUALITY,
                    temp_path
                ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                shutil.move(temp_path, ogg_path)

                print(f"✅ Successfully replaced → {ogg_path}")
                recompressed += 1

            except subprocess.CalledProcessError:
                print(f"❌ Reencoding failed: {ogg_path}")
                skipped += 1
                if os.path.exists(temp_path):
                    os.remove(temp_path)

print("\n📊 Summary:")
print(f"  Total found     : {total}")
print(f"  Recompressed    : {recompressed}")
print(f"  Skipped/Failed  : {skipped}")
