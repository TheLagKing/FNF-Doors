import math
import os
import json
import mutagen
import mutagen.ogg
import mutagen.oggvorbis

dataDir = os.path.join("./assets/preload/data", "")
songsDir = os.path.join("./assets/songs", "")

jsonDerulo = {}

def makeSongJsonFile(song):
    jsonPath = os.path.join(dataDir, song, 'metadata.json')

    # Initialize songData dictionary with required fields
    # Try to load existing metadata if it exists
    if os.path.exists(jsonPath):
        with open(jsonPath, 'r') as jsonIn:
            songData = json.load(jsonIn)
    else:
        songData = {}
    
    # Check if hell difficulty exists
    hellDirPath = os.path.join(songsDir, song + "-hell")
    songData["hasHellDiff"] = os.path.exists(hellDirPath)
    
    # Add song lengths
    songData["songLengths"] = {"easy": None, "normal": None, "hard": None, "hell": None}
    
    # Calculate normal difficulty song length
    normalInstPath = os.path.join(songsDir, song, "Inst.ogg")
    if os.path.exists(normalInstPath):
        songData["songLengths"]["normal"] = math.ceil(mutagen.oggvorbis.Open(normalInstPath).info.length)
    
    # Calculate hell difficulty song length if it exists
    if songData["hasHellDiff"]:
        hellInstPath = os.path.join(songsDir, song + "-hell", "Inst.ogg")
        if os.path.exists(hellInstPath):
            songData["songLengths"]["hell"] = math.ceil(mutagen.oggvorbis.Open(hellInstPath).info.length)

    with open(jsonPath, 'w', newline='') as jsonOut:
        jsonOut.write(json.dumps(songData, sort_keys=True, indent=4))

def whichSongHasNoMetadata():
    noMetas = []
    for dir, _, files in os.walk(dataDir):
        if(dir.endswith("-hell")): continue
        if("metadata.json" in files): continue
        else: noMetas.append(dir.removeprefix("./assets/preload/data\\"))
    return noMetas

def makeAllMetadataFiles(force:bool = False):
    noMetadatas = whichSongHasNoMetadata()
    for dir, _, files in os.walk(dataDir):
        print(dir)

        if(dir.endswith("-hell")): continue
        songName = dir.removeprefix("./assets/preload/data\\")
        print(songName)
        if(force or songName in noMetadatas):
            makeSongJsonFile(songName)
    
    print("All done !")

makeAllMetadataFiles(True)