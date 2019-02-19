<!DOCTYPE html>
<html lang="en">
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=0">
        <script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js"></script>
        <script src="/js/soundmanager2.js"></script>

        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="./css/bootstrap.min.css">

        <link rel="stylesheet" href="./css/redBtn.css">

        <link href='http://fonts.googleapis.com/css?family=Lobster' rel='stylesheet' type='text/css'>

        <!-- Latest compiled and minified JavaScript -->
        <script src="./js/bootstrap.min.js"></script>

        <style type="text/css">
            body {
                background: url('./img/LegoMovie.jpg') center 0 no-repeat;
                background-size: cover;
                margin:0;
                padding:0;
                height: 100%;
            }

            h1 {
                font-family: 'Lobster', cursive;
                text-align: center;
            }

            h2 {
                font-family: 'Lobster', cursive;
                text-align: center;
            }

            .wrapper {
                min-height: 100%;
                height: 100%;
                position: relative;
            }

            .box {
                background: #000;
                color: #fff;
                opacity: 0.8;
                text-align: center;
                overflow: hidden;
                border: 1px solid black;
                margin: 0 auto;
                max-width: 1080px;
                padding: 10px;
                padding-bottom:40px;
            }

            .overlay {
                display: none;
                position:absolute;
                top:0;
                left:0;
                right:0;
                bottom:0;
                background-color:rgba(0, 0, 0, 0.45);
                background: url(data:;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAABl0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuNUmK/OAAAAATSURBVBhXY2RgYNgHxGAAYuwDAA78AjwwRoQYAAAAAElFTkSuQmCC) repeat scroll transparent\9; /* ie fallback png background image */
                z-index:9998;
                color:white;
            }

            .footer {
                position:absolute;
                bottom:0;
                width:100%;
                background-color: #000;
                height: 40px;
            }

            .footer ul {
                list-style-type: none;
                margin: 0;
                padding: 0;
            }

            .footer a {
                padding: 10px;
                color: #fff;
                display: block;
            }

            .footer li {
                background: #000;
                display: inline;
                float: left;
            }

            .config {
                margin: 10px;
            }

            .tag {
                color: #000;
            }

            #submitBtn{
                margin: 0 auto;
                z-index: 9999;
            }

            #response{
                background: #fff;
                color: #000;
                height: 650px;
            }

            #videobcg {
                 position: absolute;
                 top: 0px;
                 left: 0px;
                 min-width: 100%;
                 min-height: 100%;
                 width: auto;
                 height: auto;
                 z-index: -1000;
                 overflow: hidden;
                 display: none;
            }

            #closeBtn {
                float: right;
                margin: 10px 20px;
                font-size: 50px;
                cursor: pointer;
            }

            .btn-default.active {
                color: #000;
                background-color: #32FF16;
                border-color: #adadad;
                font-weight: bold;
            }

        </style>
    </head>
    <body>

        <script>
            function getTags(){
                environment = $('input[class=environment]:checked').val();
                repo        = $('input[name=repo]:checked').val();

                toogleTags(false);

                // Read the users
                $.ajax({
                   url: <cfoutput>"#sDeployURL#/gitinfo.cfm?type=#lcase(url.type)#&environment="+environment+"&repo="+repo+"&ts=#getEpoch()#"</cfoutput>,
                   dataType: "json",
                   success: function(data) {
                    data.tags.sort();
                    data.tags.reverse();

                     // Convert the object to a string to display it
                    sData = JSON.stringify(data);

                    var options = '';

                    for (var i=0 ; i < data.tags.length; i++){
                        options += '<option value="'+data.tags[i]+'">'+data.tags[i]+'</option>';
                    }
                    $('#tag').html(options);
                    toogleTags(true);
                    // $('#main').html('We received this:<br />' + sData);
                   }
                });
            }

            function checkTags(){
                // Enable Live branch only if Staging or Production Environment
                if ($('input[class=environment]:checked').val() == "staging" || $('input[class=environment]:checked').val() == "production"){
                    $('[id^=branch-]').hide();
                    $('#branch-live').show();
                    $('#branch-live').prop('checked', true).trigger('click');
                } else {
                    // Other branches instead
                    $('[id^=branch-]').show();
                }

                if ($('input[name=branch]:checked').val() == "live"){
                    toogleTags(true);
                    getTags();
                    $('input[name=action]').val("tag");
                } else {
                    toogleTags(false);
                    $('input[name=action]').val("branch");
                }
            }

            function checkApplication(name){
                // Hide uat for marketplace
                if ($('input[name=repo]:checked').val() == 'marketplace'){
                    $('label[id=env-uat]').hide();
                    $('input[id=env-uat]').prop('checked', false);
                    $('label[id=env-uat]').removeClass('active');
                } else {
                    $('label[id=env-uat]').show();
                }

                // Hide staging for newsfeed and service layer
                if ($('input[name=repo]:checked').val() == 'newsfeed' || $('input[name=repo]:checked').val() == 'servicelayer'){
                    $('label[id=env-staging]').hide();
                    $('input[id=env-staging]').prop('checked', false);
                    $('label[id=env-staging]').removeClass('active');
                } else {
                    $('label[id=env-staging]').show();
                }
            }

            function toogleTags(status){
                // Make sure our select is still valid
                if ($('input[name=branch]:checked').val() != "live"){
                    status = false;
                }

                if (status == true){
                    $('.tag').show();
                } else {
                    $('.tag').hide();
                }

            }

            function scrollToEnd(){
                $('#response').scrollTop($('#response')[0].scrollHeight);
            }

            function randomSound(type){
                var sounds = {
                    positive:["OK", "Right", "ThenWhat", "TooPerfect", "Yeah", "YES", "YES1", "Good", "Good2", "Alright1", "Alright2"],
                    negative:["NO1", "NO2", "NO3", "NoImNotInterestedInThat", "NoTheyWereSpiesOrSomeSing","NoOptions","no_deal"],
                    insult:["YouIdiot", "GetYourStoryStraight", "DidHeGetARefund", "ConsiderThatADivorce", "IGiveUp", "StopIT!", "AndYouExpectMeToBelievU", "ComeOnDontBullshitMe", "StopWhining", "YouLackDiscipline", "YouMustBeVeryProudOfYourSelf", "YouSonOfABitch"],
                    identity:["WhoAreYou1","WhoIsItThisTime",""],
                    ready:["LetsDoIt","no_problemo","LetsSayUrTellingTheTruth","LetsAssumeIDo","IFeelLikeIWasMeant4SomethingMore","IWantToBeSomebody","IWantToDoSomethingWithLife"]
                }

                var random = Math.floor((Math.random() * (sounds[type].length -1)));

                var sound = sounds[type][random] + '.wav';

                playSound(sound);
            }

            function playTheme(){
                var file = "EveryThingIsAwesome.mp3";
                playSound(file);
            }

            function playSound(file){
                var src             = "/sound/";

                //alert(file);

                switch(file){
                    case "ready":
                        src += "arnoldquestions.wav";
                        break;

                    case "click":
                        src += "arnoldknow.wav";
                        break;

                   case "ok":
                        src += "no_problemo.wav";
                        break;

                    case "no":
                        src += "no_deal.wav";
                        break;

                    case "deploy":
                        src += "big_surprise.wav";
                        break;

                    case "finished":
                        src += "deep_trouble.wav";
                        break;

                    default:
                        src += file;
                        break;
                }


                var mySound = soundManager.createSound({
                    id: file,
                    url: src
                });

                mySound.play();
            }

            $(document).ready(function(){

                $.ajaxSetup({ cache: false });

                soundManager.setup({
                    url: '/swf/',
                    onready: function() {
                        setTimeout(playSound(file), 50000);
                    }
                });

                checkApplication()
                checkTags();

            <cfif bDeploy>
                var file = "finished";
                scrollToEnd();

                $('#backBtn').click(function(event) {
                    var url = window.location.protocol + '//' + window.location.host + window.location.pathname + '?type=php';
                    window.location.replace(url);
                    // window.history.back();
                });
            <cfelse>
                var file = "ready";
            </cfif>

                $('#submitBtn').click(function(event) {
                    event.preventDefault();
                    $('.config').hide();
                    $(this).hide();
                    $('#videobcg').css({
                        display: 'block'
                    });
                    playSound("deploy");
                    setTimeout(function(){ $('#deployForm').submit(); playTheme();}, 5000);
                });

                $('#confirmationModal').on('show.bs.modal', function (event) {
                  var button = $(event.relatedTarget); // Button that triggered the modal

                  var modal = $(this);

                });

                $('#confirmBtn').click(function(event) {
                    event.preventDefault();
                    if($('#user-name').val().length > 0 ){
                        randomSound("ready");

                        $('.overlay').css({
                            display: 'block'
                        });

                        $('#submitBtn').css({
                            display: 'block'
                        });

                        $('#modalError').addClass('hide');

                        $('#confirmationModal').modal('hide');
                    }else {
                        randomSound("identity");
                        $('#modalError').removeClass('hide');
                    }

                });

                // prevent enter key
                $('input[type=text]').keydown(function(event) {
                    if (event.keyCode == 13) {
                        $('#confirmBtn').click();
                        return false;
                     }
                });

                $('#modalBtn').click(function(event) {
                    if($('#user-name').val().length > 0 ){
                        randomSound("identity");
                    } else {
                        playSound("click");
                    }
                });

                $('.dismissBtn').click(function(event) {
                    randomSound("insult");
                });

                $('input[type=radio]').change(function(event) {
                    checkApplication($(this).attr('name'));
                    checkTags();
                    randomSound("positive");
                });

                $('#closeBtn').click(function(event) {
                    randomSound("insult");
                    $('.overlay').css({
                        display: 'none'
                    });

                    $('#submitBtn').css({
                        display: 'none'
                    });
                });

            });
        </script>
    <div class="wrapper">

        <cfif bDeploy>
            <div class="box">
                <div class="cluster">
                    <cfoutput>
                        <h2>#sTitle#</h2>
                        <br><br><br>
                        <div class="environment">
                            <form id="deployForm">
                                <textarea id="response" name="response" cols="80" rows="10">#sJSON.output#</textarea><br><br>
                                <button type="button" class="btn btn-primary" id="backBtn">Back</button>
                            </form>
                        </div>
                    </cfoutput>
                </div>
            </div>
        <cfelse>
            <form id="deployForm">
                <input type="hidden" name="type" value="<cfoutput>#lcase(url.type)#</cfoutput>">
            <video id="videobcg" preload="true" autoplay="true" loop="loop" muted="muted" volume="0">
                 <source src="./img/explosion.mp4" type="video/mp4">
                 <source src="./img/explosion.webm" type="video/webm">
                      Sorry, your browser does not support HTML5 video.
            </video>
            <div class="box">
                <div class="cluster">

                    <h2>Every Thing is Awesome Deployer</h2>

                    <cfif structKeyExists(url, 'debug')>
                        <input id="action" name="debug" type="hidden" value="yes">
                    </cfif>

                    <input id="action" name="action" type="hidden" value="">

                    <div class="config" >

                        <div class="environment">
                            <h3>
                                <span class="label label-primary">Environment</span>
                            </h3>
                            <div class="btn-group" data-toggle="buttons">
                                <cfscript>
                                    for (i=1; i lte listLen(lPHPEnvironments); i++){
                                        active = "";
                                        checked = "";
                                        sEnvironment = listGetAt(lPHPEnvironments, i);

                                        writeOutput('<label class="btn btn-default #active#" id="env-#lcase(sEnvironment)#" group="environment">');
                                        writeOutput('<input class="environment" type="radio" id="env-#lcase(sEnvironment)#" name="environment" value=#sEnvironment# #checked#>#uCase(sEnvironment)#</input>');
                                        writeOutput('</label>');
                                    }
                                </cfscript>
                            </div>
                        </div>

                        <div class="repo">
                            <h3>
                                <span class="label label-primary">Repo</span>
                            </h3>
                            <div class="btn-group" data-toggle="buttons">
                                <cfscript>
                                    lPHPRepos = listSort(lPHPRepos, "Text");
                                    for (i=1; i lte listLen(lPHPRepos); i++){
                                        active = "";
                                        checked = "";
                                        sRepo = listGetAt(lPHPRepos, i);

                                        writeOutput('<label class="btn btn-default #active#" >');
                                        writeOutput('<input class="repo" type="radio" id="repo" name="repo" value=#sRepo# #checked#>#uCase(sRepo)#</input>');
                                        writeOutput('</label>');
                                    }
                                </cfscript>
                            </div>
                        </div>

                        <div class="branch">
                            <h3>
                                <span class="label label-primary">Branch</span>
                            </h3>
                            <div class="btn-group" data-toggle="buttons">
                                <cfscript>
                                    //lPHPBranches = listSort(lPHPBranches, "Text");
                                    for (i=1; i lte listLen(lPHPBranches); i++){
                                        active = "";
                                        checked = "";
                                        sBranches = listGetAt(lPHPBranches, i);

                                        writeOutput('<label class="btn btn-default #active#" id="branch-#lCase(sBranches)#">');
                                        writeOutput('<input class="branch" type="radio" id="branch-#lCase(sBranches)#" name="branch" value=#sBranches# #checked#>#uCase(sBranches)#</input>');
                                        writeOutput('</label>');
                                    }
                                </cfscript>
                            </div>
                        </div>

                        <div class="tag">
                            <h3>
                                <span class="label label-primary">Tag</span>
                            </h3>
                            <select name="tag" id="tag" onChange="randomSound('positive');"></select>
                        </div>

                        <div class="submit">
                            <br>
                            <button id="modalBtn" type="button" class="btn btn-primary" data-toggle="modal" data-target="#confirmationModal">Submit</button>
                        </div>

                        <div class="overlay">
                            <span id="closeBtn">X</span>
                        </div>
                    </div>

                </div>
            </div>

            <div>
                <div class="modal fade" id="confirmationModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="alert alert-danger hide" role="alert" id="modalError">User Name is missing!!</div>
                          <div class="modal-header">
                            <button type="button" class="close dismissBtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="exampleModalLabel">Deployment Confirmation</h4>
                          </div>
                          <div class="modal-body">
                              <div class="form-group">
                                <label for="user-name" class="control-label">User:</label>
                                <input type="text" class="form-control" id="user-name" name="userName">
                              </div>
                          </div>
                          <div class="modal-footer">
                            <button type="button" class="btn btn-default dismissBtn" data-dismiss="modal">Close</button>
                            <button type="button" class="btn btn-primary" id="confirmBtn">Confirm</button>
                          </div>
                        </div>
                    </div>
                </div>

                <button id="submitBtn" class="push--skeuo" value="Deploy" style="display: none;"></button>

            </div>

        </cfif>
    </div>
<cfinclude template="/includes/footer.cfm">