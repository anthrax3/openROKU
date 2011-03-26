rm -f myApp.zip

mkdir zipit 
mkdir zipit/source
mkdir zipit/images

cp $HOME/ROKU/00_myLib/rlRSS.brs zipit/source/rlRSS.brs
cp source/* zipit/source/
cp images/* zipit/images/
cp manifest zipit/manifest

cd zipit 
zip -r myApp.zip *
cd ..
cp zipit/myApp.zip myApp.zip
rm -rf zipit

curl -s -S -F "mysubmit=Install" -F "archive=@$PWD/myApp.zip" -F "passwd=" http://10.0.0.6/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//"
read a
