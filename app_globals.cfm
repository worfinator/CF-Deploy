<cfscript>
    param name="url.type" default="cf";

    sPath           = "/export/www/wwwroot/";
    sScriptPath     = sPath & "githooks/";
    sGitURL         = "http://adgit01.apnnz.co.nz:8000/deploy";
    sDeployURL      = "http://deployment.devlbcf.apnnz.co.nz";

    // Coldfusion Deployment    
    lCFRepos          = "applogin,dynamic,jsonapi,ngm-mobile,nzherald,syndication,zen";
    lCFBranches       = "dev,sit,uat,metering,master,live";
    lCFEnvironments   = "dev,sit,uat,staging,production";
    lCFSources        = "web-development";
    lCFServers        = "adcf01,adcf02";

    // PHP Deployment 
    lPHPRepos          = "appfeed,marketplace,newsfeed,servicelayer";
    lPHPBranches       = "sit,uat,master,live";
    lPHPEnvironments   = "dev,uat,staging,production";
    lPHPSources        = "web-development";
    lPHPServers        = "adphp01";

    lValidIPs       = ["10.28.1.","10.28.69."];

    sMailTo         = "nzhdevs@groups.nzme.co.nz,codedeploy@groups.nzme.co.nz";

    lExcludeTags    = "ex_rwc_branch,2014.07.17r2,V0.10,18.03.13r0,20130807r0,20130807r1";


    bDynamicTagSource = false;

    stCFInstances     = {
        "bau"           = {
                source="web-development",
                path="development/bau",
                autodeploy = {
                    nfs="adnfs01.apnnz.co.nz",
                    active=true,
                    branch="bau",
                    type="commit",
                    email=false
                }
        },
        "dev"   = {
                source="web-development",
                path="staging/cf7",
                autodeploy = {
                    nfs="adnfs01.apnnz.co.nz",
                    active=true,
                    branch="master",
                    type="commit",
                    email=false                    
                }
        },
         "metering"           = {
                source="web-development",
                path="maxwell",
                autodeploy = {
                    nfs="adnfs01.apnnz.co.nz",
                    active=false,
                    branch="metering",
                    type="commit",
                    email=true
                }
        },
        "uat"      ={
                source="web-development",
                path="live/cf7",
                autodeploy = {
                    nfs="bunfs01.apnnz.co.nz",
                    active=false,
                    branch="live",
                    type="tag",
                    email=true
                }
        },
        "sit"      ={
                source="web-development",
                path="live/cf7",
                autodeploy = {
                    nfs="adnfs01.apnnz.co.nz",
                    active=true,
                    branch="sit",
                    type="commit",
                    email=true
                }
        },
        "staging"  ={
                source="web-development",
                path="staging/cf7",
                autodeploy = {
                    nfs="apnfs01.apnnz.co.nz",
                    active=false,
                    branch="",
                    type="",
                    email=true
                }
        },
        "production"      ={
                source="web-development",
                path="live/cf7",
                autodeploy = {
                    nfs="apnfs01.apnnz.co.nz",
                    active=false,
                    branch="",
                    type="",
                    email=true
                }
        }
    };
    sRepos          = "";

    apiSecret       = "f@%47h155h1t";
    
    // Defaults
    sEnvPath        = "";
    sSource         = "";
    sRepo           = "";
    sTag            = "";
    sBranch         = "";
    sCommit         = "";
    bValid          = false;
    bDebug          = true;

    
    public function getURL(string environment, string repo){
        var domain      = "nzherald.co.nz";
        var prefix      = "";
        var app         = "";
        var protocol    = "http";

        // URL according to Enviroment
        switch(arguments.environment){

            case "production":
                prefix  = "live";
                break;

            case "staging":
                prefix  = "staging";
                break;

            default:
                prefix  = arguments.environment;
                domain  = "devlbcf.apnnz.co.nz";
                break;
        }

        switch(arguments.repo){
            case "ngm-mobile":
                app = "ngm";
                break;

            case "zen":
                protocol = "https";
                break;

            default:
                app = arguments.repo;
                break;
        }

        var url = "#protocol#://#prefix#-#app#.#domain#";

        return url;
    }

    public function authenticate(){
        var stHeaders = GetHttpRequestData().headers;
        
        // Check the IP is valid
        for (var i=1; i lte arrayLen(lValidIPs); i++){
            if (find(lValidIPs[i] , cgi.remote_addr)
                or (structKeyExists(stHeaders, "x-forwarded-for") 
                and find(lValidIPs[i], stHeaders["x-forwarded-for"]))){
                return true;
            }
        }

        return true;
    }


    public function debug(required string message){
        if (bDebug){
            fileWrite("#sScriptPath#progress.html",arguments.message);
        }
    }

    public function convertEpoch(numeric dateSeconds){        
        // set the base time from when epoch time starts
        var startDate           = createdatetime( '1970','01','01','00','00','00' );
        
        if ( NOT isnumeric( arguments.dateSeconds ) )
            return '';
        
        // return the date
        // this adds the seconds to the startDate and the converts it to to a local time from UTC format
        return dateConvert( "utc2Local", dateadd( 's', arguments.dateSeconds, startDate ) );        
    }

    public function getEpoch(){        
            // set the base time from when epoch time starts
            var startDate       = createdatetime( '1970','01','01','00','00','00' );
            var datetimeNow     = dateConvert( "local2Utc", now() );

            // Allow for daylight savings
            if (GetTimeZoneInfo().isDSTOn){
                datetimeNow     = dateConvert( "local2Utc", dateAdd('h', 1, now()) );
            }
            
            
            
            return datediff( 's', startdate, datetimeNow );   
    }


    public function getAPIKey(required string apiSecret){
        var iEpoch              = getEpoch();
        var sHash               = lCase(hash("#iEpoch##arguments.apiSecret#", "MD5"));
        var sAPIKey             = "#iEpoch#:#sHash#";
        
        return sAPIKey;
    }

</cfscript>

<cffunction name="bashMe">
    <cfargument name="environment" type="string" required="true">
    <cfargument name="path" type="string" required="true">
    <cfargument name="source" type="string" required="true">
    <cfargument name="repo" type="string" required="true">
    <cfargument name="branch" type="string" default="" required="false">
    <cfargument name="tag" type="string" default="" required="false">

    <cftry>
        <!--- Allow for Zen admin directory --->
        <cfif lCase(arguments.repo) eq "zen">
            <cfset arguments.path &= "/admin">
        </cfif>

        <cfset var sFilePath = "#sScriptPath#deploy.sh">

        <cfscript>
            var sMessage = "<p>Running script #sFilePath#</br></br>
            with arguments: #arguments.environment# #arguments.path# #arguments.repo# #arguments.branch# #arguments.tag#</p>";

            debug(message=sMessage);

            if (bDebug){
                fileWrite("#sScriptPath#vars.html",sMessage);
            }   
        </cfscript>

        <cfexecute 
            name="#sFilePath#"
            arguments="#arguments.environment# #arguments.path# #arguments.repo# #arguments.branch# #arguments.tag#">
        </cfexecute>
        
        <cfcatch type="any">
            <cfsavecontent variable="sDump">
                <cfdump var="#cfCatch#">    
            </cfsavecontent>
            <cffile action="write" file="#sScriptPath#error.html" output="#sDump#">
            <cfabort>
        </cfcatch>
    </cftry>
</cffunction>