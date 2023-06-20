stty -echo
DIR="$( cd "$( dirname "$0" )" && pwd )"
buildSaveLocation=$HOME/Desktop
projectLocation="${DIR%/*}"
filename='scripts/releaseNotes.txt'
releaseNotes="";
Error='\033[0;31m'
Success='\033[0;32m'
NC='\033[0m' # No Color
rm -rf releaseNotes_g.txt

APP_TOKEN="6941f1ad0281c85b114f9f623fcd463ff1fe498d"

n=1
while read line; do
releaseNotes=$releaseNotes"\n"$line
n=$((n+1))
done < $filename
ReleaseNote=$releaseNotes
echo $ReleaseNote
if [ "$1" == "qa" ]; then
    iosAppName=ACML-iOS-QA
    version=1.0.197
    fi
if [ "$1" == "dev" ]; then
    iosAppName=ACML-iOS-DEV
    version=1.0.114
    fi    
if [ "$1" == "uat" ];then
    iosAppName=ACML-Android-UAR
    version=1.0.114
    fi
if [ "$1" == "cug" ];then
    iosAppName=ACML-iOS-CUG
    version=1.0.7
fi  
echo  "${Success}projectLocation $projectLocation/\n${NC}" 
echo  "${Success}buildSaveLocation $buildSaveLocation/$1_$version\n${NC}" 
echo  "$ReleaseNote\n" 

rm -rf $buildSaveLocation/$1_$version
rm -rf $projectLocation/build/app/outputs/flutter-apk/'app-'${1}'-release.apk'
rm -rf $buildSaveLocation/$1.xcarchive

mkdir -p  $buildSaveLocation/$1_$version
flavor=$1
appSub=`echo $flavor| tr [a-z] [A-Z]`
# appcenter login
if [ "$2" -eq 1 ];
then
echo Release Android  >> releaseNotes_g.txt
echo "Android $1_$version Apk Building"   >> releaseNotes_g.txt
fvm flutter build apk --flavor $1 -t lib/main_$1.dart --release 
cp $projectLocation/build/app/outputs/flutter-apk/'app-'${1}'-release.apk' $buildSaveLocation/$1_$version/
cp $projectLocation/build/app/outputs/flutter-apk/'app-'${1}'-release.apk' $buildSaveLocation/$1_$version/$1_$version.apk

AndroidFile=$buildSaveLocation/$1_$version/'app-'${1}'-release.apk'  >> releaseNotes_g.txt
if [ -f "$AndroidFile" ]; 
then  
printf "Android $1_$version Build Succeeded\n"  >> releaseNotes_g.txt
if [ "$5" -eq 1 ]; 
then
 appcenter distribute release --app Arihant-Cap/'ACML-Android-'$appSub'' --file $buildSaveLocation/$1_$version/'app-'${flavor}'-release.apk' --group "QA Team"    --token $APP_TOKEN  --release-notes "$ReleaseNote"
#  sh scripts/android.sh $1 "$ReleaseNote" $4 $buildSaveLocation/$1_$version
echo Android $1_$version Released to Appcenter  >> releaseNotes_g.txt
fi
else
printf "Android Build Failed\n" >> releaseNotes_g.txt
fi
fi
if [ "$3" -eq 1 ]; 
then
 rm -rf $buildSaveLocation/$1.xcarchive
echo Archieve $iosAppName_$version  >> releaseNotes_g.txt
xcodebuild archive -workspace ios/Runner.xcworkspace -scheme $1 -archivePath $buildSaveLocation/$1.xcarchive >> releaseNotes_g.txt
echo $1 Archeived  >> releaseNotes_g.txt
xcodebuild -exportArchive -archivePath $buildSaveLocation/$1.xcarchive -exportPath $buildSaveLocation/$1_$version -exportOptionsPlist $projectLocation/ios/ExportOptions_$1.plist  >> releaseNotes_g.txt
cp  $buildSaveLocation/$1_$version/acml.ipa $buildSaveLocation/$1_$version/$1_$version.ipa

echo $1 ipa exported  >> releaseNotes_g.txt
iOSFile=$buildSaveLocation/$1_$version/'acml.ipa'  >> releaseNotes_g.txt
if [ -f "$iOSFile" ]; then  
printf "IOS $1_$version Build Succeeded\n"
if [ "$5" -eq 1 ]; 
then
 appcenter distribute release --app Arihant-Cap/''$iosAppName'' --file $buildSaveLocation/$1_$version/'acml.ipa' --group "QA Team"    --token $APP_TOKEN  --release-notes "$ReleaseNote"

# sh scripts/ios.sh $1 "$ReleaseNote" $4  $iosAppName $buildSaveLocation/$1_$version
echo  $iosAppName_$version Released to Appcenter  >> releaseNotes_g.txt
fi
else
printf "IOS $1_$version Build Failed\n"  >> releaseNotes_g.txt
fi
fi




