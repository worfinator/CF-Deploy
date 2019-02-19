<cfsetting requesttimeout="900">

<cfscript>
    param name="url.type" default="cf";

    deploymentServer = 'myserver.com';

    include "app_globals.cfm";

    // redirect to the home page if not valid ip
    if (not authenticate()){
        location("http://www.nzherald.co.nz");
    }

    bDeploy             = false;
    sJSON = {
        'status' = false,
        'output' = '',
        'message' = ''
    };


    if (structKeyExists(url, 'action')
        and len(url.action)){

        if (structKeyExists(form, "type") and len(form.type)){
            url.type    = form.type;
        }

        // Get the API Key
        sAPIKey         = getAPIKey(apiSecret);
        sURL            = sGitURL&'?apiKey=#sAPIKey#&type=#lcase(url.type)#&environment=#lCase(url.environment)#&repo=#lCase(url.repo)#';

        if (structKeyExists(url, "resets")){
            sURL        &= '&resets=#lCase(url.resets)#';
        }

        if (url.action eq "branch" and structKeyExists(url, "branch") and len(url.branch)){
            bDeploy     = true;
            sURL        &= "&branch=#url.branch#";
            sTitle      = "Deploying #uCase(url.repo)# #url.branch# branch to #uCase(url.environment)#";
        }

        if (url.action eq "tag" and structKeyExists(url, "tag") and len(url.tag)){
            bDeploy     = true;
            sURL        &= "&tag=#url.tag#";
            sTitle      = "Deploying #uCase(url.repo)# tag #url.tag# to #uCase(url.environment)#";
        }

        if (structKeyExists(url, "userName") and len(url.userName)){
            sURL        &= "&name=#url.userName#";
        }

        // Debug
        if (structKeyExists(url, "debug") or structKeyExists(form, 'debug')){
            url.debug   = 'yes';
            writeDUmp(var=url, label='URL');
            writeOutput('
                </br></br>
                APIKey: #sAPIKey#</br></br>
                Daylight savings is on: #GetTimeZoneInfo().isDSTOn#</br></br>
                <a href="#sURL#&debug=yes" target="_blank">Deployment API Link</a>
            ');
            abort;
            
        }

        // Build HTTP request
        oHTTP           = new http();
        oHTTP.setMethod("get");
        oHTTP.setCharset("utf-8");
        oHTTP.setURL(sURL);

        // Call API
        stResult        = oHTTP.send().getPrefix();

        //writeDump(toString(stResult.fileContent));abort;

        if (stResult.statusCode eq "200 OK"){
            sContent    = toString(stResult.fileContent);
            //sContent    = replace(sContent, "\n", "<br>", "all");
            sJSON       = deserializeJSON(sContent);
        } else {
            sJSON    = {
                'status' = 'Error',
                'output' = 'Error contacting remote Deployment API service on #deploymentServer#. Please make sure the server is running.'
            };
        }

    }

    // Define which template to show
    sTemplate = "includes/#lCase(url.type)#deploy.cfm";
</cfscript>

<cfinclude template="#sTemplate#">
