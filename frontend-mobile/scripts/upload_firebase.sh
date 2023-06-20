
DIR="$( cd "$( dirname "$0" )" && pwd )"

projectLocation="${DIR%/*}"

buildSaveLocation=$HOME/Desktop
echo $projectLocation
# $projectLocation/ios/Pods/FirebaseCrashlytics/upload-symbols -gsp $projectLocation/ios/Firebase/cug/GoogleService-Info.plist -p ios $buildSaveLocation/dSYMs
$projectLocation/ios/Pods/FirebaseCrashlytics/upload-symbols -gsp $projectLocation/ios/Firebase/uat/GoogleService-Info.plist -p ios $buildSaveLocation/dSYMs
# $projectLocation/ios/Pods/FirebaseCrashlytics/upload-symbols -gsp $projectLocation/ios/Firebase/qa/GoogleService-Info.plist -p ios $buildSaveLocation/dSYMs