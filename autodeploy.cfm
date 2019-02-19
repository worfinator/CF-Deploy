<cfscript>
include "app_globals.cfm";

// Get the request body
sRequestBody    = toString(getHTTPRequestData().content);

// Lets do it!!
try {

    // Only proceed if it is valid JSON
    if (isJSON(sRequestBody)){

        // Save JSON as a structure
        stJSON      = deserializeJSON(sRequestBody);

        // Save a copy for review
        saveContent variable="sDump" {
            writeDump(stJSON);
        }

        if (bDebug) fileWrite("#sScriptPath#rawJSON.html",sDump);

        // Make sure we have a valid packet
        if (structKeyExists(stJSON, "repository") and structKeyExists(stJSON.repository, "url") and len(stJSON.repository.url) and structKeyExists(stJSON, "ref") and len(stJSON.ref)){

            // make sure we are dealing with a tagged release
            if (listLen(stJSON.ref,"/")){
                

                // If this is a tagged release
                if (listFindNoCase(stJSON.ref,"tags","/")){
                    sTag        = listGetAt(stJSON.ref, listLen(stJSON.ref,"/"), "/");
                    sBranch     = "live";
                } else {
                    sCommit     = stJSON.after;
                    sBranch     = listGetAt(stJSON.ref, listLen(stJSON.ref,"/"), "/");
                }


                // Get all of our common params             
                sTemp           = listGetAt(stJSON.repository.url, 2, ":");
                sSource         = listGetAt(sTemp, 1, "/");
                sRepo           = listGetAt(listGetAt(sTemp, listLen(sTemp,"/"),"/"), 1, ".");
                                
                // Only deal with repos within the supported sources
                if (listFind(lCFSources, lCase(sSource)) and listFindNoCase(lCFRepos, sRepo)){

                    debug(message="Found Matching Source #sSource# and Repo #sRepo#</br></br>");
                    
                    // Loop through the Server Environments
                    lCFEnvironments       = structKeyList(stCFInstances);

                    for (i=1; i lte listLen(lCFEnvironments); i++){
                        sEnvironment    = listGetAt(lCFEnvironments, i); 
                        stEnvironment   = stCFInstances[sEnvironment];
                        sEnvPath        = stEnvironment.path;

                        debug(message="Tag #sTag# / Branch #sBranch#</br></br>");

                        // If this is a valid match to the instances listed for auto deploy
                        if (len(sBranch) and listFindNoCase(stEnvironment.autodeploy.branch, sBranch) and listFindNoCase(stEnvironment.source, sSource) and stEnvironment.autodeploy.active){
                        
                            debug(message="Found Matching #sEnvironment# Environment</br></br>commit:#sCommit# tag:#sTag# env:#stEnvironment.autodeploy.type#");

                            // Commits
                            if (len(sCommit) and listFindNoCase(stEnvironment.autodeploy.type, "commit")){
                                debug(message="Updating #sEnvironment# #sRepo# based on Commit #sCommit#</br></br>");
                                bValid = true;

                                // Run the bash file
                                bashMe(environment=sEnvironment, path=sEnvPath, source=sSource, repo=sRepo, branch=sBranch);
                            }

                            //Tags
                            if (len(sTag) and listFindNoCase(stEnvironment.autodeploy.type, "tag")){
                                debug(message="Updating #sEnvironment# #sRepo# based on Tag #sTag#</br></br>");
                                bValid = true;
                                // Run the bash file
                                bashMe(environment=sEnvironment, path=sEnvPath, source=sSource, repo=sRepo, branch=sBranch, tag=sTag);
                            }

                        }

                    }

                    // If we didn't find a match
                    if (not bValid){
                        debug(message="No Matching Environment Config found for #sEnvironment# #sRepo# Tag #sTag# / Branch #sBranch#</br></br>");
                    }

                } 


                if (not bValid){
                    sDump       = "Invalid jSON";                   
                }


            } else {
                sDump           = "Failed on reference";
            }

        } else {
            sDump               = "Failed on repository look up";
        } 


    } else {
        writeOutput("No JSON received");
        sDump                   = "I'm not Jason!";
    }
}

catch (any e){
    saveContent variable="stError" {
        writeDump(e);
    }

    if (bDebug) fileWrite("#sScriptPath#error.html",stError);
}   

if (bDebug) fileWrite("#sScriptPath#raw.html",sDump);
</cfscript>
