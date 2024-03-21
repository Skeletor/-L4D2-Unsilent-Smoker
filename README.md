# [L4D1/2] Unsilent Smoker
Whenever you encounter the AI smoker and it's preparing to attack, it emits the
distnguishable 'warning' sound.<br>

However you may have seen situations where one performs the attack without
making the noise at all (or it gets almost insta interrupted/silenced).<br>

It happens when the smoker isn't facing you directly before performing the attack, and 
his 'warning' sound gets interrupted by the 'spot prey' sound.<br>
	
This plugin simply blocks the 'spot prey' sound if the previous smoker's sound was
the 'warning' one.<br>

Works for both L4D1 and L4D2.<br><br>

-= Installation =-
1. Install sourcemod and metamod (preferably the latest versions) here:<br>
   https://www.sourcemod.net/downloads.php<br>
   https://www.sourcemm.net/downloads.php?branch=stable<br><br>
2. Place 'l4d2_unsilent_smoker.smx' into 'addons/sourcemod/plugins' folder.<br>
3. (Local servers only) Run your game with '-insecure' launch option.
