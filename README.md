# CF-Deploy

CF_Deploy is a ColdFusion based Deployment interface that allows users to select a git tag to push to a deployment server.

## Installation

Step 1.) 
Copy the index.cfm and deploy.sh to the remote you wish to run the deployment scripts on. Make sure deploy.sh has execute permissions for the webmastr user.

Step 2.)
Create a webhook within the project you wish to deploy from within the Gitlab project settings. It will need to point to the server you have installed index.cfm and deploy.sh.

Step 3.)
Edit index.cfm to include the appropriate Groups and Project repos.

Step 4.)
Edit deploy.sh to carry out the tasks you need to perform.

Step 5.)
Load the deployment endpoint in the browser. http://myserver.com/index.cfm

Step 6.)
Enjoy the LEGO goodness
