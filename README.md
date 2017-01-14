# Simple GUI bash DBMS
this is a bash enabled database managment system developed by me for bash shell scripting assignment at ITI (open source)
![alt text](https://github.com/salamaashoush/bashDBMS/raw/master/screenshot.png "DBMS Screen shoot")
### Installation
DBMS requires [yad](https://sourceforge.net/projects/yad-dialog/)  to run

Download and extract the source code and open it in terminal
Install the dependencies (ubuntu) try to find equivalent packages for other distrubutions
```sh
$ sudo apt-get install build-essential libgtk-3-0 libgtk-3-dev libgtksourceview-3.0-dev libwebkitgtk-3.0-dev
```
#####Now  lets build (in the extracted folder)
```sh
$ ./configure --enable-html  --enable-sourceview --with-gtk=gtk3
$ make
$ sudo make install
```
#####Now open DBMS Folder and type 
```sh
$ chomd +x *
$ ./start.sh
```
#####to open it without terminal
- Open Nautilus 
- Open Preferences.
- Choose Behavior tab. Under Executable Text Files choose Ask each time or Execute them.

### DBMS Commands 
#####type the Command and hit (Ctrl+Enter) Key and use just one command at a time 
```sh
$ create database database_name
$ show databases
$ use database_name
$ drop database database_name
$ create table table_name (name:data_type,name:data_type....)
$ show tables
$ insert into table table_name (value,value,...)
$ select all from table_name
$ select row row_number from table_name
$ delete row row_number from table_name
$ drop table table_name
$ update 
$ exit 
```
### Development
Want to contribute? Great!
my DBMS uses bash  + yad or zenity for gui.
##### Big Thanks to my dear friend [Dr-AhmedAmer](https://github.com/Dr-AhmedAmer) for his Continued support 


