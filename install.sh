#!/bin/bash
#Use at your own risk, the author can not be held responsible for any damage of any kind.
#Run from your home directory at KTH, NOT FROM ANY SSH SERVER!
#Also, don't run when my.nada.kth.se is down.

echo "[BS] OpenGL package installation, one moment.."
sleep 2
cd ~

#copy lib and include stuff
mkdir gltut gltut/lib gltut/inc gltut/bin
sftp share-01:/usr/lib/libGL*.so gltut/lib/
#cp /usr/lib/libGL*.so gltut/lib/
sftp share-01:/usr/include/GL/* gltut/inc/
#cp /usr/include/GL gltut/inc/

#download and unzip tutorials
echo "Downloading Tutorial files.."
wget -q -O Tut --no-check-certificate "https://bitbucket.org/alfonse/gltut/downloads/Tutorial%200.3.7.7z"

#sftp my:/usr/bin/7z .
echo "Unzipping.."
ssh my '7z x Tut -ogltut'
mv gltut/Tutorial\ 0.3.7/* gltut/
rm Tut

#download premake4
echo "Downloading premake4.."
wget -q "http://sourceforge.net/projects/premake/files/Premake/4.3/premake-4.3-linux.tar.gz/download"
tar xzf download
chmod +x premake4
mv premake4 gltut/bin/
rm download

echo "Install done!"

#build stuff
echo "Building framework and glsdk.."

cd gltut

~/gltut/bin/premake4 gmake
mv Makefile Makefile2
echo -e "LDFLAGS=-L../lib\nINCLUDES=-I../inc\n" > Makefile
cat Makefile2 >> Makefile
rm Makefile2

#replace "version 330" with "version 150"
echo "Downgrading GLSL version.."
find . -type f -print0 | xargs -0 sed -i 's/version 330/version 150/g'

sed -i 's/glutInitContextVersion (3, 3)/glutInitContextVersion (3, 2)/g' framework/framework.cpp

cd glsdk
~/gltut/bin/premake4 gmake
make; make config=release
cd ../framework
~/gltut/bin/premake4 gmake
make; make config=release
cd ../tinyxml
~/gltut/bin/premake4 gmake
make; make config=release

echo "Build tutorials (Y) or skip them and save ~200 MB (n)?"
read choice

if [ "$choice" != "Y" ]; then
	echo "Done."
	exit
fi

cd ..
~/gltut/bin/premake4 gmake
make; make config=release

./Tut\ 01\ Hello\ Triangle/Tut\ 01\ MainD &

echo "Done."
