package backend.updating;

import sys.FileSystem;
import haxe.io.Path;
import backend.github.GitHubRelease;
import backend.github.GitHub;
import lime.app.Application;

using backend.github.GitHub;

class UpdateUtil {
	public static final repoOwner:String = "Leetram519";
	public static final repoName:String = "FNF-Doors-Public";
	
	public static function init() {
		#if sys
		var bakPath = '${Path.withoutExtension(Sys.programPath())}.bak';
		if (FileSystem.exists(bakPath))
			FileSystem.deleteFile(bakPath);
		#end
	}

	public static function checkForUpdates():UpdateCheckCallback {
		var curTag = 'v${Application.current.meta.get('version')}';	
		
		var error = false;

		var newUpdates = __doReleaseFiltering(GitHub.getReleases(repoOwner, repoName, function(e) {
			error = true;
		}), curTag);

		if (error) return {
			success: false,
			newUpdate: false
		};
		
		if (newUpdates.length <= 0) {
			return {
				success: true,
				newUpdate: false
			};
		}

		return {
			success: true,
			newUpdate: true,
			currentVersionTag: curTag,
			newVersionTag: newUpdates[newUpdates.length - 1].tag_name,
			updates: newUpdates
		};
	}

	static var __curVersionPos = -2;
	static function __doReleaseFiltering(releases:Array<GitHubRelease>, currentVersionTag:String) {
		var tempReleases = releases.filterReleases(false, false);
		releases = tempReleases;
		if (releases.length <= 0)
			return releases;

		var newArray:Array<GitHubRelease> = [];

		var skipNextBinaryChecks:Bool = false;
		for(index in 0...releases.length) {
			var i = index;
			var release = releases[i];

			//prevent checking older versions
			if (release.tag_name <= currentVersionTag) {
				continue;
			}

			var containsBinary = skipNextBinaryChecks;
			if (!containsBinary) {
				for(asset in release.assets) {
					if (asset.name.toLowerCase() == AsyncUpdater.executableGitHubName.toLowerCase()) {
						containsBinary = true;
						break;
					}
				}
			}
			if (containsBinary) {
				skipNextBinaryChecks = true; // no need to check for older versions
				if (release.tag_name == currentVersionTag) {
					__curVersionPos = -1;
				}
				newArray.insert(0, release);
				if (__curVersionPos > -2)
					__curVersionPos++;
			}
		}

		if (__curVersionPos < -1)
			__curVersionPos = -1;

		return newArray.length <= 0 ? newArray : [newArray[newArray.length - 1]];
	}
}

typedef UpdateCheckCallback = {
	var success:Bool;

	var newUpdate:Bool;

	@:optional var currentVersionTag:String;

	@:optional var newVersionTag:String;

	@:optional var updates:Array<GitHubRelease>;
}