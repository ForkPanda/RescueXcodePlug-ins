# !/bin/sh
echo '
    _/_/_/                              _/            _/    _/  _/    _/      
   _/    _/    _/_/_/  _/_/_/      _/_/_/    _/_/_/  _/  _/        _/_/_/_/   
  _/_/_/    _/    _/  _/    _/  _/    _/  _/    _/  _/_/      _/    _/        
 _/        _/    _/  _/    _/  _/    _/  _/    _/  _/  _/    _/    _/         
_/          _/_/_/  _/    _/    _/_/_/    _/_/_/  _/    _/  _/      _/_/                                                                        
'

find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`

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
