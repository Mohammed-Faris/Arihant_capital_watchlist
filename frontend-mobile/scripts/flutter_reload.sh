fvm flutter clean
cd ios
pod deintegrate
rm -rf Pods
rm -rf Podfile.lock
rm -rf Runner.xcworkspace
cd ..
fvm flutter pub get
cd ios
pod install --repo-update
cd ..