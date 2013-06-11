Crosslinker
===========

Crosslinking Coupled Mass Spectroscopy Data Analysis Software

(c) Andrew N Holding

Installation
------------

This is a brief guide to how to install Crosslinker and assumes a working knowledge of Linux. It is recommended that Crosslinker is run on a fresh [Debian Linux](http://debian.org) installation and the the server is not accessible via the internet. 

Required packages not included in the standard Debian installation are:

* apache2
* mysql-server (when prompted set root password to 'crosslinker')
* git
* libparallel-forkmanager-perl
* libdbd-sqlite3-perl
* libdbd-mysql-perl
* libchart-gnuplot-perl

These can be installed with 'apt-get' or 'aptitude'.

	e.g. apt-get install apache2 

Make and change to directory '/srv/www'. 

	e.g. mkdir /srv/www; cd /srv/www

Use Git to obtain the latest version of Crosslinker and download it into the current directory. 

	e.g. git clone git://github.com/andrewholding/Crosslinker.git

Change ownership of the folder to www-data with chown.

	e.g. chown www-data:www-data /srv/www -R

Update Apache's default site file or create a new site definintion to point to the Crosslinker install.

	e.g. nano /etc/apache2/sites-available/default

You should be now able to access Crosslinker by connecting to the server with a webrowser.
