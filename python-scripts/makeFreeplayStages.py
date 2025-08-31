import json
import os

dataDir = os.path.join("./assets/preload/data", "")

def main():
    for dir, _, files in os.walk(dataDir):
        if dir == dataDir: continue
        songName = dir.removeprefix("./assets/preload/data\\")
        for file in files:
            if(songName not in file): continue

            difficulty = file.removesuffix(".json").removeprefix(songName).removeprefix("-")
            jsonDerulo = getSongJson(songName, difficulty)
            if jsonDerulo == json.loads("{}"): return "Something went horribly wrong ! Check if you entered the correct name or difficulty."

            if("freeplayStage" not in jsonDerulo["song"]):
                jsonDerulo["song"]["freeplayStage"] = jsonDerulo["song"]["stage"]

            writeNewSongFile(jsonDerulo, songName, difficulty)
            
    print("All modifications finished!")

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

if __name__ == "__main__":
    main()