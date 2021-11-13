# Clean up
rm -rf smart-pill-organizer/bin
rm -rf smart-pill-organizer/src-gen

# # Build C codes from LF
../lfc/bin/run/lfc smart-pill-organizer/src/Main.lf

# # Remove bin as we will build the PICO executable ourselves
rm -rf smart-pill-organizer/bin

# Use our own core and CMakeLists
rm -rf smart-pill-organizer/src-gen/Main/core
rm -rf smart-pill-organizer/src-gen/Main/build
rm smart-pill-organizer/src-gen/Main/CMakeLists.txt

cp -r lib-support/core smart-pill-organizer/src-gen/Main/core
cp lib-support/CMakeLists.txt smart-pill-organizer/src-gen/Main/CMakeLists.txt

cd smart-pill-organizer/src-gen/Main
mkdir build
cd build
cmake ..
make -j4

open .