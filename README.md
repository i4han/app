#Satellite
A webapp development framework written in CoffeeScript based on Meteor.

##Install
$ ./install.sh

##Directories and files
	apps: Where Apps located.
	   getber: current app directory
	   index.coffee: App source file.
	lib: Satellite lib files. account, menu, ui
	meteor: Meteor packages are being developed and current working app copy.
	style: theme, css, less, sass files
	work: just work files.

	.config.json: configuration file needed by cake
	.settings.cson: Applicataion setting file
	.settings.json: Processed .settings.cson by cake used by meteor settings.
	Cakefile: server housekeepping program. compile, build, copy files.
	install.sh: Install npm modules and create profile.

##cake command
	$ cake settings  # create .settings.json file
	$ cake meteor    # start meteor with port:3000 for app or port:3300 for package app
	$ cake build     # build files and copy nessassary media files.

##meteor command
	$ cake settings
	$ cd apps/getber/app
	$ meteor --port 3000 --settings ../../../.settings.json
	 
	$ cd meteor
	$ meteor --port 3300 --settings ../.settings.json



##Todo
- ~~Restructure bin, app, module, etc, home directories~~
- ~~dsync into Cakefile~~
- ~~accounts.coffee, transfer accounts.js to coffee~~
- ~~side menu~~
- ~~watch config file 'cake config'~~
- ~~watch lib files 'cake sync'~~
- ~~scrollspy, contentEditable to header~~
- _id management jquery .data
- db id management
- subscribe/publish
- $db, $cfg, $tmpl and $_.
- merge files in client
- dialog
- change main menu when you log in
- use exteral mongo db
- library in lib
- structured id generator
- data model
- Style, theme, color selector, size selector 
- Internationalization, language, message files
- Form generator. jquery muliselect, slide, card form
- Server side rendering
- Automated page listing.


##License
Non-commercial, personal, or open source projects and applications, you may use under the terms of the GPL v3 License. Commercial project and application,
a commercial license is required.