<cfsetting showdebugoutput="no" requesttimeout="1600">
<cfheader name="Content-Type" value="application/json">

<cfscript>
    include "app_globals.cfm";

    // Only perform if we have a path 
    if (structKeyExists(url, "environment") and structKeyExists(url, "repo")){
        if (url.type is 'cf'){
        
            sPrefix         = "";
            if (lCase(url.repo) eq "zen"){
                sPrefix     = "admin/";
            }

            // Change the repo to match adgit01  name format
            url.repo        = replace(url.repo, "-", "_", "all");

            // Support Dynamic Tag source (i.e. allow to get tags from different locations BAU/Dev/Staging/Production)
            if (bDynamicTagSource){
                sArgs       = "#sPath##stCFInstances[lCase(url.environment)].path#/#sPrefix##lCase(url.repo)#";
            } else {
                // Get from live/cf source (SIT)
                sArgs       = "#sPath#live/cf7/#sPrefix##lCase(url.repo)#";
            }

            sResult         = getGitInfo(sScriptPath, sArgs);

            
        }

        if (url.type is 'php'){
            sArgs = "#sPath#live/php/#lCase(url.repo)#";

            sResult         = getGitInfo(sScriptPath, sArgs);
        }


        // Get Tags as clean list
        lTags               = listChangeDelims(sResult, ',', #chr(10)#);

        // Clean up tags
        for (t=1; t lte listLen(lExcludeTags); t++){
            sExcludeTag     = listGetat(lExcludeTags, t);
            iMatchIndex     = listFind(lTags, sExcludeTag);
            // Delete matching tag
            if (iMatchIndex){
                lTags       = listDeleteAt(lTags, iMatchIndex);
            }
        }

        // Return jSON packet
        stReturn            = {
            "environment"   = lCase(url.environment),
            "path"          = sArgs,
            "tags"          = listToArray(lTags)
        };

        writeOutput(serializeJSON(stReturn));

    } 
</cfscript>

<cffunction name="getGitInfo" returntype="String">
    <cfargument name="scriptPath" type="string" required="true">
    <cfargument name="args" type="string" required="true">

    <cfset var sResult = "">

    <cfexecute timeout="120" variable="sResult" name="#arguments.scriptPath#gitinfo.sh" arguments="#arguments.args#"></cfexecute>

    <cfreturn sResult>
</cffunction>   