import json
import os
import math

EMPTY_SECTION = json.loads("""
{
    "sectionBeats": 4,
    "sectionNotes": [],
    "typeOfSection": 0,
    "gfSection": false,
    "altAnim": false,
    "mustHitSection": false,
    "changeBPM": false,
    "bpm": 150
}
""")

def main(songName:str, difficulty:str, offsetByBeats:int):
    jsonDerulo = getSongJson(songName, difficulty)
    if jsonDerulo == json.loads("{}"): return "Something went horribly wrong ! Check if you entered the correct name or difficulty."

    bpm = float(jsonDerulo["song"]["bpm"])
    jsonDerulo = offsetJson(jsonDerulo, getBeatMilliseconds(bpm) * offsetByBeats)
    jsonDerulo = addMissingSections(jsonDerulo, getBeatMilliseconds(bpm) * offsetByBeats, bpm)

    writeNewSongFile(jsonDerulo, songName, difficulty)

def addMissingSections(jsonDerulo, offsetToAddToAll:float, bpm:float):
    if(offsetToAddToAll < getSectionMilliseconds(bpm)): return

    numberOfSections = math.floor(offsetToAddToAll / getSectionMilliseconds(bpm))
    for i in range(0, numberOfSections):
        jsonDerulo["song"]["notes"].insert(0, EMPTY_SECTION)

    return jsonDerulo

def offsetJson(jsonDerulo, offsetToAddToAll:float):
    notes = jsonDerulo["song"]["notes"]
    for i in range(0, len(notes)):
        for j in range(0, len(jsonDerulo["song"]["notes"][i]["sectionNotes"])):
            jsonDerulo["song"]["notes"][i]["sectionNotes"][j][0] += offsetToAddToAll

    return jsonDerulo

def getSongJson(songName:str, difficulty:str):
    diffString = (f"-{difficulty}" if len(difficulty) > 1 else "")
    dataDir = os.path.join("./assets/preload/data", songName, f"{songName}{diffString}.json")
    if not os.path.exists(dataDir): return json.loads("{}")
    jsonDerulo = json.loads("".join(open(dataDir, "r").readlines()))

    return jsonDerulo

def writeNewSongFile(jsonDerulo, songName:str, difficulty:str):
    diffString = (f"-{difficulty}" if len(difficulty) > 1 else "")
    dataDir = os.path.join("./assets/preload/data", songName, f"{songName}{diffString}.json")
    open(dataDir, "w").write(json.dumps(jsonDerulo, indent=4))

def getBeatMilliseconds(bpm:float):
    if(bpm <= 0): return
    
    return (1000 * 60) / bpm

def getSectionMilliseconds(bpm:float):
    return getBeatMilliseconds(bpm) * 4

if __name__ == "__main__":
    print(main(
        input("Please enter the song name you wish to offset [NON-CAPITALIZED, THE IN-GAME FILE NAME] - "),
        input("Please input the difficulty you want to change [LEAVE EMPTY OF NORMAL, IT MUST BE THE SAME AS IN THE GAME FILES] - "),
        int(input("By how many beats do you want to delay the song ? [INT ONLY] - "))
    ))