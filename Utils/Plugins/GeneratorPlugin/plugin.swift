//
//  plugin.swift
//  
//
//  Created by Егор Яковенко on 15.03.2022.
//

import PackagePlugin

@main
struct SwiftGenPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        print(context.pluginWorkDirectory)
        return [
            .prebuildCommand(
                displayName: "Running Sourcery",
                executable: Path("/usr/local/bin/sourcery"),
                arguments: [
                    "--line-directive", "''",
                    "-o", "Sources/Utils/Generated/Secret.swift",
                    "Templates/Secret.swift.gyb"
                ],
                outputFilesDirectory: Path("Sources/Utils/Generated"))
        ]
    }
    
//    find . -name "*.gyb" |
//    while read file; do
//        filename=$(echo "$file" | sed 's/.\///')
//        API_ID=$1 API_HASH=$2 gyb --line-directive '' -o "../Sources/Utils/Generated/${filename%.gyb}" "$filename";
//    done
}
