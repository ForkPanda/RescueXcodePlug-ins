#!/bin/sh
echo '
    _/_/_/                              _/            _/    _/  _/    _/      
   _/    _/    _/_/_/  _/_/_/      _/_/_/    _/_/_/  _/  _/        _/_/_/_/   
  _/_/_/    _/    _/  _/    _/  _/    _/  _/    _/  _/_/      _/    _/        
 _/        _/    _/  _/    _/  _/    _/  _/    _/  _/  _/    _/    _/         
_/          _/_/_/  _/    _/    _/_/_/    _/_/_/  _/    _/  _/      _/_/                                                                        
'

v=$1
if [ "$v" == "" ] ;then
    v=7.1.1
fi

echo "Try to rescue your Xcode " $v "..."

find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID

defaults delete com.apple.dt.Xcode DVTPlugInManagerNonApplePlugIns-Xcode-$v

if [ $? -eq 0 ];then
  echo "\nRescue Success!Restart your Xcode and choose 'Load Bundles' option"
else
  echo "\nRescue Failed!"
fi