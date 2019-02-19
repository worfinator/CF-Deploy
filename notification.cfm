<cfsilent>
    
    <cfscript>
        include "app_globals.cfm";

        param name="url.e" default="";
        param name="url.r" default="";
        param name="url.b" default="";
        param name="url.t" default="";
        param name="url.p" default="";

        bSuccess    = false;
        sContent    = "";
        sURL        = "";

        try{

            if (len(url.e) and listFindNoCase(structKeyList(stCFInstances), url.e)){
                stEnvironment=stCFInstances[lCase(url.e)];
                if (len(url.r)){
                    sURL = getURL(url.e, url.r);
                }
                
                // Only send email if active
                if (stEnvironment.autodeploy.email){

                    sNFS = stEnvironment.autodeploy.nfs;

                    savecontent variable="sContent" {
                        writeOutput('
                            New code was deployed in the <b>#url.e#</b> environment.</br></br>

                            Branch: <b>#url.b#</b></br>');

                        if (len(url.t)){
                            writeOutput('
                            Tag: <b>#url.t#</b></br>');
                        }

                        writeOutput('</br>
                            Actioned by: <b>GitHooks</b></br></br>

                            Server: <b>#sNFS#</b></br>
                            Folder: <b>/export/www/wwwroot/#url.p#/#url.r#</b></br>
                           
                        ');

                        // Add URL is applicable
                        if (len(sURL)){
                            writeOutput('
                            View changes at: #sURL#</br>');
                        }
                    }

                    // Build Email message
                    mail = new mail();
                    mail.setSubject("New code deployed in #url.e# environment");
                    mail.setTo("#sMailTo#");
                    mail.setFrom("GitHooks Deployment System <no-reply@myserver.com>");
                    //mail.addPart( type="text", charset="utf-8", wraptext="72", body="#sContent#");
                    mail.addPart( type="html", charset="utf-8", body="<p>#sContent#</p>" );

                    // Send Email
                    mail.send();

                    bSuccess = true;
                }
            }
        }

        catch(any e){
            // Do nothing
            bSuccess = false;
        }
    </cfscript>

</cfsilent>

<cfif bSuccess>
    <cfoutput>Deployment email sent</br></cfoutput>

    <cfscript>
        httpService = new http();
        httpService.setMethod("get");
        httpService.setCharset("utf-8");        

        // Server Resets
        for (i=1; i lte listLen(lCFServers); i++){
            sServer = replace(sURL,'devlbcf',listGetAt(lCFServers,i));
            sReset = "#sServer#status/health-check.cfm?key=mySecretKey&reset=yes&resetappdata=yes";
            httpService.setUrl(sReset);
            httpService.send();
            writeOutput("Resetting #sServer#</br>");
        }
    </cfscript>

<cfelse>
    <cfoutput>Error sending deployment email</cfoutput>    
</cfif>
