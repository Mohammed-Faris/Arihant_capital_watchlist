
DIR="$( cd "$( dirname "$0" )" && pwd )"
buildSaveLocation=$HOME/Desktop
projectLocation="${DIR%/*}"
filename='scripts/releaseNotes.txt'
releaseNotes="";
Error='\033[0;31m'
Success='\033[0;32m'
NC='\033[0m' # No Color
n=1
while read line; do
releaseNotes=$releaseNotes"\n"$line
n=$((n+1))
done < $filename
ReleaseNote=$releaseNotes
if [ "$1" == "qa" ]; then
    iosAppName=ACML-iOS-QA
    version=1.0.197
    fi
if [ "$1" == "uat" ];then
    iosAppName=ACML-Android-UAR
    version=1.0.114
    fi
if [ "$1" == "cug" ];then
    iosAppName=ACML-iOS-CUG
    version=1.0.7
    fi
if [ "$1" == "dev" ]; then
   iosAppName=ACML-iOS-DEV
   version=1.0.114    
fi 
echo $buildSaveLocation/$1_$version/app-$1-release.apk
echo $buildSaveLocation/$1_$version/acml.ipa
echo $projectLocation/ios/ExportOptions_$1.plist

flutter build apk --flavor $1 -t lib/main_$1.dart --release
cp $projectLocation/build/app/outputs/flutter-apk/'app-'${1}'-release.apk' $buildSaveLocation/$1_$version/
cp $projectLocation/build/app/outputs/flutter-apk/'app-'${1}'-release.apk' $buildSaveLocation/$1_$version/$1_$version.apk

sh  scripts/telegram.sh -f /Users/akash/Documents/Akash-Documents/navigator_20_example.zip  -t 5737707668:AAGfDi1iNOUN8bh4wJacr0-5FFG9myjwma4 -c -1001868557635 -M "$message" 
#  curl -v --http1.1  https://upload.diawi.com/ -F token="MDnOjBwmnDlT9CvsxAjsHAnsfvkxRYaUVMXW4tDx6l" -F file=@$buildSaveLocation/$1_$version/app-$1-release.apk -F find_by_udid=0 -F callback_emails='narmadha.b@marketsimplified.com,akash.a@marketsimplified.com'

flutter build appbundle  --flavor qa -t lib/main_qa.dart --target-platform android-arm,android-arm

