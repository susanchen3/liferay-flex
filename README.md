# liferay-flex
For all things Flex related


## How to use the Hotfix script:
**Background** 

This version of the script: 
- downloads the bundle, patching tool, fixpack and hotfix 
- places the mysql.jar, activation key and portal-ext.properties
- clears the logs, data osgi/folder
- drops and creates the lportal database
- ONLY need to input password, portal version, fixpack number and hotfix number

**Setup**

The script is dependent on the setup of the hotfix folder. You can just download my hotfix folder which contains:
- setup.sh script
- portal-ext.properties
- mysql.jar and folder for 7.0 mysql.jar
- activation keys 6.0-7.4
  - if replacing keys, ensure the new key begins with "activation-key..."

In setup.sh, you need to change the username to your own liferay email.
- On line 18, replace USER@liferay.com

**Steps**
- where setup.sh is located, open terminal and run `bash setup.sh dlhf`
- **prompts** `Specify which portal version [7.3, 7.2, 7.1, 7.0, 6.2, other]:`
  - input one of the supported versions
    - ex. 7.3
  - if need a different version then input "other"
- **prompts** `Password:`
  - input your liferay password
- if version is 7.3, 7.2, 7.1, 7.0, 6.2 then it will download their respective bundle and patching tool
- if other, you have to manually input the bundle and patching tool link
- **prompts** `Does this hotfix require a fixpack? Please type Y or N:`
  - input Y or N
- if Y, **prompts** `Fixpack number:`
  - input the fixpack number 
    - ex. 2
- **prompts** `Hotfix number:`
  - input the hotfix number
    - ex. 2907
- does the rest of the setup (clearing folders & db, placing mysql.jar & portal-ext & activation key)
- now you can navigate to tomcat/bin and run `./catalina.sh run` :)
