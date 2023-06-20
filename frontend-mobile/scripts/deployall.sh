

# brew install jq
# install JQ if not previously installed
# flutter clean
# flutter pub get
cd ios
pod update Firebase/CoreOnly
pod install
cd ..

# sh scripts/deploy.sh cug 1 1 true 1
#  sh scripts/deploy.sh uat 1 1 true 1
#  sh scripts/deploy.sh uat 1 1 false 1
# sh scripts/deploy.sh cug 1 1 true 1
#  sh scripts/deploy.sh cug 1 1 true 1

# sh scripts/deploy.sh uat 1 1 true 1

# sh scripts/deploy.sh qa 1 1 true 1
# sh scripts/deploy.sh cug 1 1 true 1
# sh scripts/deploy.sh uat 1 1 true 1
# sh scripts/deploy.sh uat 1 1 true 1

sh scripts/deploy.sh cug 1 1 true 1
# sh scripts/deploy.sh uat 1 1 true 1

# sh scripts/deploy.sh uat 1 1 true 0
# sh scripts/deploy.sh qa 1 0 true 1

# sh scripts/deploy.sh cug 1 1 true 1

# sh scripts/deploy.sh qa 0 1 true 1

# sh scripts/deploy.sh qa 1 1 false 1


#  sh scripts/deploy.sh cug 1 1 true 1

#  sh scripts/deploy.sh uat 1 1 true 1

# sh scripts/deploy.sh cug 1 1 false 1
# qa defines the flavor
# 1 denotes Android build 0 denotes dont take Android build
# 1 denotes IOS build 0 denotes dont take IOS build
# true denotes enable Notification
# 1 denotes Release to appcenter
