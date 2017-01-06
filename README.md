TTT_Spectator_Deathmatch
========================

Spectator Deathmatch for Trouble in Terrorist Town (a Garry's Mod gamemode)

This addon allows dead players to enter a deathmatch mode with each other. The living players won't be able to see or hear you, and you'll be given a random primary/secondary to battle each other with. Find the other "Ghosts" and kill them. This continues until the end of the current round. To enter or leave the deathmatch, type !deathmatch or !specdm into chat.

http://facepunch.com/showthread.php?t=1426936


Some features:
- Statistics.
- Loadout on F1.
- Easy to config : command name, enabling/disabling loadout, pointshop rewards, popup after dying, rank restriction, etc..
- Visual effect : the world is grey and only ghosts are colored.
- Includes Dota2-like quake sounds (killstreak sounds).
- Creates a new scoreboard section to see the list of spectator deathmatch players.

#####For *stable* releases look here: https://github.com/Tommy228/TTT_Spectator_Deathmatch/releases

How to install : Just drop the TTT_Spectator_Deathmatch folder to addons/.

**On Linux servers, you need to make the foldername lowercase!**

And don't forget to update your FastDL (or use the workshop) and edit the specdm_config.lua file!


###Known bugs:
- On some maps ghost players can get stuck. Rejoining the Spectator Deathmatch is currently the only solution.


##Upcoming features:

* Cleaner code and example template for creating own ghost weapons
* Add an update notification (like 'TTT Damagelogs' has)


#License:

    This addon allows dead players to enter a deathmatch mode with each other.
    Copyright (C) 2017  Ismail Ouazzany

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

####TTT Spectator Deathmatch uses the following 3rd party software:
- https://github.com/vercas/vON from Vercas
