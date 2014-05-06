---
layout: post
title: Flashing CM11 (M6) to my Samsung Glaxy S3 (i9300)
---

I've been running CM10 on my S3 for over a year now. In the past
couple of months, performance and stability have become really
poor. There are weird stalls (especially on text input, Google
Hangouts and the Gallery). These range from 3-5s to 30s at
times. Rebooting my phone never helps. I tried the "empty file
creator" technique which is meant to help with SD card fatigue, but I
didn't notice any difference.

When I originally flashed CM onto my phone, I put the latest version
of clockwork recovery on my phone. That version is not compatible with
CM11. Also, some folk claim that doing a full wipe is in your best
interest when making this upgrade. Furthermore, gapps stability on
CM11 has been reportedly poor.

Given the fact that my phone has been trending towards being unusable,
I decided that I really didn't have much to lose at this point. #yolo.

My first attempt was using the new-fangled CM installer available on
get.cm. I followed the instructions but the Windows component wouldn't
install because it detected that there was a newer version. So, I went
for the manual route.

This is pretty straight forward. The gist of it is that you need to:

* Flash a compatible recovery ROM onto your phone
* Transfer CM11 and gapps onto your phone
* Use the recovery ROM to install CM11 and gapps

I did this all from OSX (Mavericks).

## Files needed

Grab the following:

* http://cdn.bitbucket.org/benjamin_dobell/heimdall/downloads/heimdall-suite-1.4.0-mac.dmg
* http://oss.reflected.net/jenkins/67685/cm-11-20140504-SNAPSHOT-M6-i9300.zip
* http://download2.clockworkmod.com/recoveries/recovery-clockwork-6.0.4.6-i9300.img
* https://dl.google.com/android/adt/22.6.2/adt-bundle-mac-x86_64-20140321.zip
* http://gapps.itvends.com/gapps-kk-20140105-signed.zip

## Flash the latest version of clockwork recovery

* Install the Heimdall suite and reboot your laptop
* Switch your phone off
* Switch it on
* Hold down home+power+volume-down until you enter download mode
* Confirm you are awesome with volume-up
* Plug USB into laptop
* sudo heimdall flash --RECOVERY recovery-clockwork-6.0.4.6-i9300.img --no-reboot
* Power off (hold power button)
* Went into a bit of a boot spin
* Boot into clockwork with home+power+volume-up

### Notes

* If you get 'ERROR: Failed to receive response!' when running
  `heimdall flash`, try unplug the cable and power cycle your phone.
* After I flashed clockwork, my phone when into a reboot spin. I
  yanked the battery.
* My first boot into recovery took a while to display the
  menu. Subsequent boots were fast.

## Installing Cyanogen Mod v11 M6

* Install the Android Development Toolkit and change into `sdk/platform-tools`
* In recovery, choose to install update from zip file
* I did a full wipe before doing this
* Choose sideload -- you will be prompted to run `adb sideload`. I ran
  `adt-bundle-mac-x86_64-20140321/sdk/platform-tools/adb sideload
  $HOME/Downloads/cm-11-20140504-SNAPSHOT-M6-i9300.zip`
* Go back to the main menu and boot into CM
* Do the first-run setup and make sure things work
* Boot back into recovery
* Sideload gapps. For me, `adb sideload $HOME/Downloads/gapps-kk-20140105-signed.zip`
* Reboot again and run gmail to do the Google setup

### Notes

* Sideloading is really quick - a few seconds
* The "installing update" step never logged out that it completed. But
  Clockwork let me use the many after a few minutes to reboot the
  phone, so I did, and things worked.
* You can probably install CM11 and gapps without rebooting in
  between, but I like baby steps

## Results

So far I'm very happy. My phone is very responsive and I haven't had
any stalls or crashes yet. I had to install all my apps again, but
that didn't take too long. 10/10, would recommend.
