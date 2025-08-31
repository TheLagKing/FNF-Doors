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

class HashMacro {
    #if GLASSHAT
    macro public static function buildHashCSV(): Expr {
        var currentDirectory = "./assets/preload/data";
        var fileHashes = [];

        function processDirectory(path:String) {
            if (!FileSystem.exists(path)) {
                Context.warning('Directory $path does not exist', Context.currentPos());
                return;
            }

            for (file in FileSystem.readDirectory(path)) {
                var fullPath = path + "/" + file;
                if (FileSystem.isDirectory(fullPath)) {
                    processDirectory(fullPath);
                } else if (file.endsWith(".json")) {
                    var dirParts = fullPath.split("/");
                    var dirName = dirParts[dirParts.length - 2];

                    if (file.toLowerCase().indexOf(dirName.toLowerCase()) == -1) continue;

                    if (file.indexOf("hell") != -1 && path.indexOf("hell") == -1) continue;

                    var fileNameParts = file.split(".");
                    var nameWithoutExt = fileNameParts[0];
                    var nameSegments = nameWithoutExt.split("-");
                    var diffPart = nameSegments[nameSegments.length - 1];
                    var diff = ["easy", "hard", "hell"].indexOf(diffPart) != -1 ? diffPart : "normal";

                    var content = try File.getContent(fullPath) catch(e:Dynamic) {
                        Context.warning('Failed to read $fullPath: $e', Context.currentPos());
                        continue;
                    };

                    var hash = Md5.encode(content + GlasshatData.chartPepper);

                    fileHashes.push({ song: dirName.replace("-hell", ""), diff: diff, hash: hash });
                }
            }
        }

        processDirectory(currentDirectory);

        var outputDir = "./OUTPUT";
        if (!FileSystem.exists(outputDir)) {
            FileSystem.createDirectory(outputDir);
        }
        var outputPath = outputDir + "/sql_requests.txt";
    
        var sqlStatements = [];
        for (entry in fileHashes) {
            var song = StringTools.replace(entry.song, "'", "''");
            var diff = StringTools.replace(entry.diff, "'", "''");
            var hash = StringTools.replace(entry.hash, "'", "''");
    
            var sql = '
                INSERT INTO public.song ("songName") VALUES (\'$song\') ON CONFLICT DO NOTHING;
                INSERT INTO public.chart ("songID", "diffID", "hash")
                VALUES (
                    (SELECT public.song."songID" FROM public.song WHERE public.song."songName" = \'$song\'),
                    (SELECT public.difficulty."diffID" FROM public.difficulty WHERE public.difficulty."appendName" = \'-$diff\'),
                    \'$hash\'
                )
                ON CONFLICT ("songID", "diffID") DO UPDATE
                SET hash = \'$hash\'
                WHERE public.chart."songID" = (SELECT public.song."songID" FROM public.song WHERE public.song."songName" = \'$song\')
                AND public.chart."diffID" = (SELECT public.difficulty."diffID" FROM public.difficulty WHERE public.difficulty."appendName" = \'-$diff\');
            ';
    
            sqlStatements.push(sql);
        }
    
        try {
            File.saveContent(outputPath, sqlStatements.join("\n"));
        } catch (e:Dynamic) {
            Context.warning('Failed to write SQL file: $e', Context.currentPos());
        }

        return macro null;
    }
    #else
    macro public static function buildHashCSV(): Expr {
        return macro null;
    }
    #end
}