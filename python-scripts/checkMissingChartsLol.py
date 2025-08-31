import glob
import os

###
#
#       Hi Tibu ! I changed your file so that it uses os instead of glob, as glob doesn't do well with
#       relative pathing and positioning. I'd be happy if you could change that to a glob, i couldn't
#       figure it out myself :(
#
#       File function has not changed as of 22/08/24
#
###

filenames = os.listdir(os.path.join("./assets/preload/data/", ""))
chartsMissing = []
excludeSongs = ["workloud", "test", "catnip", "abnormality", "angry-spider", "can-you-glitch-my-heart",
                "daddy-issues", "drip", "enjoy-your-stay", "mobile-gaming", "sandpaper", "scrumptuous",
                "sencounter", "sweet-dreams", "these-halls-see-all", "pause-jtk", "always-lurking", "workloud-pico",
                #songs that are getting a remake
                ]

checkedSongs = []

for file in filenames:
    noend = file.replace("\\", "").replace("-hell", "")

    if noend not in excludeSongs and noend not in checkedSongs:
        checkedSongs.append(noend)

        if not os.path.isdir(os.path.join("./assets/preload/data/", file)): continue
        chartFiles = os.listdir(os.path.join("./assets/preload/data/", file))
        
        chartfilesfixed = []
        
        for name in chartFiles:
            chartfilesfixed.append(name.replace("\\", "").replace('.json', ''))
        
        chartEasy = noend + '-easy'
        
        if chartEasy not in chartfilesfixed:
            chartsMissing.append(chartEasy)
            
        chartHard = noend + '-hard'
        
        if chartHard not in chartfilesfixed:
            chartsMissing.append(chartHard)

print(chartsMissing)
