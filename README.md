# dependency-track-check

[中文](README.zh-CN.md)

<h3>Your star is my motivation to keep going. If you like this project, please help me with a star in the upper right corner.</h3>

#### Description
This project is a third-party open-source library vulnerability scanning tool. By running shell scripts, it is easy to scan for vulnerabilities in third-party open source libraries introduced in the project and upload the results to the Dependency-Track server.

#### Software Architecture
Use Maven's dependency-track plugin to check the code library and upload the results to the Dependency-Track server.

#### Instructions

1.  Enter the src directory
2.  Modify the information in the file named config  
First line: Address of the Dependency-Track server   
Line 2: User token for the Dependency-Track server
3.  Open a tool that supports shell commands in the current directory
4.  Enter the execution command (either a or b)  
a.Check from remote git warehouse：
./dtcheck-anywhere.sh [The warehouse address of the remote git project that needs to be checked] [Branch Name]  
Description: Receive two parameters, separated by spaces between them. The first parameter is the address of the git remote warehouse for the item to be checked (required); The second parameter is the remote (origin) branch name of git (optional), defaults to master.  
b.Check from local git project：  
./dtcheck-project.sh [The full root directory path of the local git project that needs to be checked] [Whether to pull the latest code from the remote warehouse] [Branch Name]  
Description: Receive three parameters, separated by spaces between them. The first parameter, the full root path of the local git project (required), specifies the full root path of the local git project to be checked; The second parameter is whether to pull the latest code of the remote git warehouse (required), y - Yes, other - No; The third parameter, the branch name of the git (optional), specifies the local branch of the git to be checked (which will switch to), defaults to the current branch.

#### Attentions
1.  Install git locally and configure global environment variables
2.  Install Maven locally and configure global environment variables
3.  The project is built on Maven

#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request
