# mosyle-tools
This is a collection of scripts that I use to manage MacOS devices within Mosyle.

## Contents
### Backblaze.sh
This is a modification of the [official deployment script for JAMF](https://help.backblaze.com/hc/en-us/articles/115002603173-Mac-Silent-Deployment) that uses Mosyle's variables. It should be deployed as a custom command within Mosyle. You will need to enter your group ID and token from your backblaze account and set your preferred region. You will also need to create a Privacy profile to give Backblaze full disk access. The privacy profile can only be completed after Backblaze has been successfully installed on at least one device in your environment.
