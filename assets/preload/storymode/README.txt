THIS IS WHERE YOU'D STORE STORY MODE FILES.

The basic one where all info is put should be normal.json.
In the easy.json, hard.json, and hell.json files you should either :
- Put everything that is in the normal.json file
- OR Put only the overrides. It'll load the normal.json file, then override only things that changed.


SPECIAL CASES : 

songPools, **IF** you override it, make sure that you write the ENTIRE thing.
As soon as you override "songPools" in your diff.json file, it'll remove everything from the normal diff, 
and use yours instead.

musicData, **IF** you override it, make sure that you write the ENTIRE thing.
As soon as you override "musicData" in your diff.json file, it'll remove everything from the normal diff, 
and use yours instead.

puzzlePool > spawnArgs, always write the ENTIRE thing, otherwise the game will freak out.