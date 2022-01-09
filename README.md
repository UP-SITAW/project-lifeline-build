# project-lifeline-build

Installation:
- Install Docker
- Install Git
- Pull latest code of this repository:
<br/><code>git pull origin master</code><br />
- run the application using this command:
<br /><code>docker-compose up --build</code><br />

Note:
- Make sure the up-pgh database is imported and all of its base data are already existing. If not execute script inside <code>sql_script</code> folder.
- This script should install the following inside of containers: <p><p>up-pgh(lifeline backend server),<br />rxbox-manager,<br /> and mysql server.