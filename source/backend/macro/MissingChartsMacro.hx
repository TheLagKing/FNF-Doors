package backend.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Md5;
#if GLASSHAT
import glasshatsec.Glasshat.GlasshatData;
#end

using StringTools;

class MissingChartsMacro {
    macro public static function checkMissingCharts(): Expr {
        var dataDir = "./assets/preload/data";
        var excludeSongs = [
            "workloud", "test", "catnip", "abnormality", "angry-spider",
            "can-you-glitch-my-heart", "daddy-issues", "drip", "enjoy-your-stay",
            "mobile-gaming", "sandpaper", "scrumptuous", "sencounter", "sweet-dreams",
            "these-halls-see-all", "pause-jtk", "always-lurking", "workloud-pico"
        ];
        var checkedSongs = [];
        var chartsMissing = [];

        function processSongDir(dirPath:String) {
            var dirName = dirPath.split("/").pop();
            var cleanName = dirName.replace("\\", "").replace("-hell", "");
            
            // Skip excluded and already checked songs
            if (excludeSongs.indexOf(cleanName) != -1 || checkedSongs.indexOf(cleanName) != -1) return;
            checkedSongs.push(cleanName);

            // Get chart files in directory
            var chartFiles = try FileSystem.readDirectory(dirPath) catch(e:Dynamic) {
                Context.warning('Error reading $dirPath: $e', Context.currentPos());
                return;
            };

            // Check for required charts
            var hasEasy = false;
            var hasHard = false;
            
            for (file in chartFiles) {
                if (!file.endsWith(".json")) continue;
                
                var chartName = file.substr(0, file.length - 5); // Remove .json
                if (chartName == cleanName + "-easy") hasEasy = true;
                if (chartName == cleanName + "-hard") hasHard = true;
            }

            if (!hasEasy) chartsMissing.push(cleanName + "-easy");
            if (!hasHard) chartsMissing.push(cleanName + "-hard");
        }

        // Main processing
        if (!FileSystem.exists(dataDir)) {
            Context.warning('Chart directory $dataDir not found', Context.currentPos());
            return macro null;
        }

        for (entry in FileSystem.readDirectory(dataDir)) {
            var fullPath = dataDir + "/" + entry;
            if (FileSystem.isDirectory(fullPath)) {
                processSongDir(fullPath);
            }
        }

        // Save results
        var outputDir = "./OUTPUT";
        try {
            if (!FileSystem.exists(outputDir)) FileSystem.createDirectory(outputDir);
            File.saveContent(outputDir + "/missing_charts.txt", chartsMissing.join("\n"));
        } catch(e:Dynamic) {
            Context.warning('Failed to save results: $e', Context.currentPos());
        }

        return macro null;
    }
}