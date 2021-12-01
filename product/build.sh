# Clean up
echo "Cleaning up build directory ..."
./clean.sh
echo "Cleaning up build directory. Done!"

# # Build C codes from LF
echo "Building Lingua-Franca codes into C ..."
../lfc/bin/run/lfc smart-pill-organizer/src/Main.lf 2> /dev/null 1> /dev/null
echo "Building Lingua-Franca codes into C. Done!"

# # Remove bin as we will build the PICO executable ourselves
echo "Building C codes into PICO executable ..."
rm -rf smart-pill-organizer/bin

# Use our own core and CMakeLists
rm -rf smart-pill-organizer/src-gen/Main/core
rm -rf smart-pill-organizer/src-gen/Main/build
rm smart-pill-organizer/src-gen/Main/CMakeLists.txt

cp -r lib-support/core smart-pill-organizer/src-gen/Main/core
cp lib-support/CMakeLists.txt smart-pill-organizer/src-gen/Main/CMakeLists.txt
cp -r lib-support/waveshare smart-pill-organizer/src-gen/Main/waveshare

cd smart-pill-organizer/src-gen/Main
mkdir build
cd build


cmake ..
make -j4

echo "Building C codes into PICO executable. Done!"

open .