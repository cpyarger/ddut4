DDRRE's Linux Server Administration & Deployment Suite for UT4

A set of installation, maintenance, and launcher scripts for GNU/Linux-based Unreal Tournament servers. Written in bash.

Features

    Install a server or hub from scratch, and update it with a URL whenever a new build is available, with the ability to update the configuration in bulk.
    Edit server configuration files
    Launch / automatically launch & monitor server instances
    Designed to fully support multiple servers on the same machine.


Installation and Configuration Summary

1. Extract the attached archive to your base directory of choice

    Configure (edit) ddut4.conf
    (optional) Provide Engine.ini, SRVNAME-Game.ini, SRVNAME-Rules.ini files to apply configuration
    Typical configuration templates are available under the conf_templates directory. Copy the files to your configuration directory to use them.
        
2. Install / update with updateServer.sh

    If .ini files are found in the base directory, they will be pushed to the SRVNAMES. Engine.ini is global to all SRVNAMES. This only happens when updateServer is executed to completion.
    Edit Game.ini and Rules.ini files with editConfig.sh and editRules.sh
    The files will also be synced to your base directory as SRVNAME-Game.ini and SRVNAME-Rules.ini when you're done editing.

3. Launch a server instance:

    Automatic (preferred method): Automatically launch and monitor servers with ut4wd.sh
        Example: ./ut4wd.sh HUB
    Manual: Launch/stop servers directly with launchServer.sh (read more below)
    
    Restart a server by running launchServer.sh SRVNAME restart & followed by the disown command.
    Stop a server by running launchServer.sh SRVNAME stop.
                Note: If ut4wd.sh is running in the background, a new server instance will eventually be started!

Upgrades

        Please note that ddut4.conf pre-v0.4 isn't backward-compatible. You must transfer your settings manually.
        Upgrading between versions: Simply copy over all *.sh files and ddut4_init.def.
        Upgrading from v0.4b to 0.4c: Same procedure + edit ddut4.conf, and remove all lines under the 3rd section (Additional Tweaks).


Todo / Wishlist

        Make start/stop/restart procedures easier (right now you can use launchServer to start, stop, or restart, but it doesn't go into background).
        Add "stop" functionality to ut4wd.sh
        Create first-time-wizard to generate INI files
        Create a hub and attach preconfigured dedicated instances, also deployed by the script (depends on feature support by the game itself, which is currently undetermined).
        Compare source-INI maplist to user's maplist, if defined, and offer new maps if available
        Add editEngine.sh and combine to a unified editor (depending on demand, based on comments below) 


More info and tech deepdive: https://forums.unrealtournament.com/showthread.php?18077-DDUT4-Linux-Server-Administration-amp-Deployment-Suite

Snir Hassidim, 2016
