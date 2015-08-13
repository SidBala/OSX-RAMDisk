#!/usr/bin/env bash -x

# This is about to create a RAM disk in OS X and move the apps caches into it
# to increase performance of those apps.
# Performance gain is very significat, particularly for browsers and
# especially for IDE
#
# Drawbacks and risks are that if RAM disk becomes full - performance will degrate
# significantly.
#
# USE AT YOUR OWN RISK.
#

# The RAM amount you want to allocate for RAM disk. One of
# 1024 2048 3072 4096 5120 6144
# todo: set default value to 1/4 of RAM
ramfs_size_mb=12288
mount_point=/Volumes/ramdisk
ramfs_size_sectors=$((${ramfs_size_mb}*1024*1024/512))
ramdisk_device=`hdid -nomount ram://${ramfs_size_sectors}`
USERRAMDISK="$mount_point/$USER"

# Checks user agreenes
user_response()
{
 read -p " $1 [y/n]" ${response}
  case ${response} in
    [yY][eE][sS]|[yY]|"")
      true
      ;;
    [nN][oO]|[nN])
      false
      ;;
    *)
      user_response $@
      ;;
  esac
}

mk_ram_disk()
{
    # unmount if exists the RAM disk and mounts if doesn't
    umount -f ${mount_point}
    newfs_hfs -v 'ramdisk' ${ramdisk_device}
    mkdir -p ${mount_point}
    mount -o noatime -t hfs ${ramdisk_device} ${mount_point}

    # Hide RAM disk - we don't really need it to be annoiyng in finder.
    # comment out should you need it.
    # hide_ramdisk

    mkdir -pv /Users/$USER/Scratch
    ln -v -s ${USERRAMDISK}/Scratch ~
}

# ------------------------------------------------------
# Application which needs the cache to be moved to RAM
# add yours at the end.
# -------------------------------------------------------

# Google Chrome Cache
move_chrome_cache()
{
    if [ -d "/Users/$USER/Library/Caches/Google/Chrome" ]; then
            if user_response "I found chrome. Do you want move its cache?" ; then
                /bin/mkdir -p /tmp/Google/Chrome
                /bin/mv ~/Library/Caches/Google/Chrome/* /tmp/Google/Chrome/
                /bin/mkdir -pv ${USERRAMDISK}/Google/Chrome/Default
                /bin/mv /tmp/Google/Chrome/ ${USERRAMDISK}/Google/Chrome
                /bin/ln -v -s -f ${USERRAMDISK}/Google/Chrome/Default ~/Library/Caches/Google/Chrome/Default
            fi
        else
            echo "No Google chrome folder has been found. Skiping"
    fi
}

# Chrome Canary Cache
move_chrome_chanary_cache()
{
    if [-d "Users/$USER/Library/Caches/Google/Chrome\ Canary"]; then
        if user_response "I found Chrome Canary. Do you want move its cache?"; then
            /bin/rm -rf ~/Library/Caches/Google/Chrome\ Canary/*
            /bin/mkdir -p ${USERRAMDISK}/Google/Chrome\ Canary/Default
            /bin/ln -s ${USERRAMDISK}/Google/Chrome\ Canary/Default ~/Library/Caches/Google/Chrome\ Canary/Default
        fi
    fi
}

# Safari Cache
move_safari_cache()
{
    if [ -d "Users/$User/Library/Caches/com.apple.Safari" ]; then
        if user_response "Do you want to move Safari cache?"; then
            /bin/rm -rf ~/Library/Caches/com.apple.Safari
            /bin/mkdir -p ${USERRAMDISK}/Apple/Safari
            /bin/ln -s ${USERRAMDISK}/Apple/Safari ~/Library/Caches/com.apple.Safari
        fi
    fi
}

# iTunes Cache
move_itunes_cache()
{
    /bin/rm -rf /Users/$USER/Library/Caches/com.apple.iTunes
    /bin/mkdir -pv ${USERRAMDISK}/Apple/iTunes
    /bin/ln -v -s ${USERRAMDISK}/Apple/iTunes ~/Library/Caches/com.apple.iTunes
}

# Intellij Idea
move_idea_cache()
{
   # make a backup of config - will need it when uninstalling
   cp -f /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties.back
   # Idea will create those dirs
   echo "idea.system.path=$USERRAMDISK/Idea" >> /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties
   echo "idea.log.path=$USERRAMDISK/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties
}

# Webstorm
move_webstorm_cache()
{
   # make a backup of config - will need it when uninstalling
   cp -f /Applications/WebStorm.app/Contents/bin/idea.properties /Applications/WebStorm.app/Contents/bin/idea.properties.back
   # Idea will create those dirs
   echo "idea.system.path=$USERRAMDISK/Idea" >> /Applications/WebStorm.app/Contents/bin/idea.properties
   echo "idea.log.path=$USERRAMDISK/Idea/logs" >> /Applications/WebStorm.app/Contents/bin/idea.properties
}

# Intellij Idea
move_ideace_cache()
{
   # todo add other versions support and CE edition
   # make a backup of config - will need it when uninstalling
   cp -f /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties.back
   # Idea will create those dirs
   echo "idea.system.path=$USERRAMDISK/Idea" >> /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties
   echo "idea.log.path=$USERRAMDISK/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties
}

# todo Android Studio
move_android_studio_cache()
{
    echo "moving Android Studio cache";
    echo "Not implemented"
}

# Closes passed as arg app
close_app()
{
    osascript -e "quit app \"${1}\""
}

# Open an application
open_app()
{
     osascript -e "tell app \"${1}\" to activate"
}

# Hide RamDisk directory
hide_ramdisk()
{
    /usr/bin/chflags hidden ${mount_point}
}

copy_gits_dir()
{
	mkdir -pv ${USERRAMDISK}/Scratch/Gits
	cp -r /Users/$USER/Gits ${USERRAMDISK}/Scratch
}

copy_tmp_dir()
{
	mkdir -pv ${USERRAMDISK}/Scratch/tmp
	cp -r /Users/$USER/tmp ${USERRAMDISK}/Scratch
}

# -----------------------------------------------------------------------------------
# The entry point
# -----------------------------------------------------------------------------------
# Let's close the apps we moving caches for in case they are running.
close_app "IntelliJ Idea 14"
close_app "IntelliJ Idea 14 CE"
close_app "WebStorm"
close_app "Google Chrome"
close_app "Safari"
close_app "iTunes"
# and create our RAM disk
mk_ram_disk
# move the caches
move_chrome_cache
move_safari_cache
move_idea_cache
move_ideace_cache
move_webstorm_cache
move_itunes_cache
# copy_gits_dir
# copy_tmp_dir
echo "All good - I have done my job"
#
# open_app "Google Chrome"
# -----------------------------------------------------------------------------------
