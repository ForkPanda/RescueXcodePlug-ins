# !/bin/sh
echo '
    _/_/_/                              _/            _/    _/  _/    _/      
   _/    _/    _/_/_/  _/_/_/      _/_/_/    _/_/_/  _/  _/        _/_/_/_/   
  _/_/_/    _/    _/  _/    _/  _/    _/  _/    _/  _/_/      _/    _/        
 _/        _/    _/  _/    _/  _/    _/  _/    _/  _/  _/    _/    _/         
_/          _/_/_/  _/    _/    _/_/_/    _/_/_/  _/    _/  _/      _/_/                                                                        
'
PLISTBUDDY="/usr/libexec/PlistBuddy"

new_DVTPlugInCompatibilityUUID=$(defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID)
echo "The new DVTPlugInCompatibilityUUID is $new_DVTPlugInCompatibilityUUID
"

OLDIFS=$IFS
IFS="$(printf '\n\b')"
path1=~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins
path2=~/Library/Developer/Xcode/Plug-ins

addUUID(){
  cd $1
  PLUGINS_DIR=$(pwd -P)
  plugin_plist_paths=$(find "$PLUGINS_DIR" -name Info.plist -maxdepth 3)

  OLDIFS=$IFS
  IFS="$(printf '\n\b')"
  for plugin_plist_path in $plugin_plist_paths; do
    trimmed_plist_path=$(echo ${plugin_plist_path##*Plug-ins/})
    plugin_name=$(echo ${trimmed_plist_path%%/*})

    DVTPlugInCompatibilityUUIDs_needs_update=false

    for (( i = 0; ; i++ )); do
      existed_DVTPlugInCompatibilityUUID=$($PLISTBUDDY -c "Print :DVTPlugInCompatibilityUUIDs:$i" "$plugin_plist_path" 2> /dev/null)
      if [ $existed_DVTPlugInCompatibilityUUID ]; then
        if test $existed_DVTPlugInCompatibilityUUID = $new_DVTPlugInCompatibilityUUID; then

          echo "DVTPlugInCompatibilityUUID existed in $plugin_name"

          # $PLISTBUDDY -c "Delete :DVTPlugInCompatibilityUUIDs:$i string" $plugin_plist_path
          DVTPlugInCompatibilityUUIDs_needs_update=false
          break
        fi
      else
        DVTPlugInCompatibilityUUIDs_needs_update=true
        break
      fi
    done

    if [[ $DVTPlugInCompatibilityUUIDs_needs_update = true ]]; then
      $PLISTBUDDY -c "Add :DVTPlugInCompatibilityUUIDs: string $new_DVTPlugInCompatibilityUUID" $plugin_plist_path
      echo "DVTPlugInCompatibilityUUID added to $plugin_name"
    fi
  done
  IFS=$OLDIFS
}

addUUID $path1
addUUID $path2
IFS=$OLDIFS

ls=`defaults read com.apple.dt.Xcode | grep -o 'DVTPlugInManagerNonApplePlugIns-Xcode-[^\"]*'`

for x in $ls; do
    echo "Try to rescue your Xcode" ${x##*-} "..."
    defaults delete com.apple.dt.Xcode $x

    if [ $? -eq 0 ]; then
        echo "Ok"
    else
        echo "Err"
    fi

done

if [ "$ls" != "" ];then
  echo "\nRescue Success!Restart your Xcode and choose 'Load Bundles' option!"
else
  echo "\nError!Cannot find any config of Plug-ins in your Library!"
  echo "* You have been run the script maybe."
  echo "* Try to restart Xcode and check wheather it works."
fi
