#!/bin/bash


# Check where we're being run from.
if [ -d Octave ]; then
	cd Octave
	fi

# Find libsndfile shared object.
libsndfile_lib_location=""

if [ -f "../src/.libs/libsndfile.so" ]; then
	libsndfile_lib_location="../src/.libs/"
elif [ -f "../src/libsndfile.so" ]; then
	libsndfile_lib_location="../src/"
elif [ -f "../src/.libs/libsndfile.dylib" ]; then
	libsndfile_lib_location="../src/.libs/"
elif [ -f "../src/libsndfile.dylib" ]; then
	libsndfile_lib_location="../src/"
else
	echo "Not able to find the libsndfile shared lib we've just built."
	exit 1
	fi
libsndfile_lib_location=`(cd $libsndfile_lib_location && pwd)`


# Find sfread.oct and sfwrite.oct
sfread_write_oct_location=""

if [ -f .libs/sfread.oct ]; then
	sfread_write_oct_location=".libs"
elif [ -f sfread.oct ]; then
	sfread_write_oct_location="."
else
	echo "Not able to find the sfread.oct/sfwrite.oct binaries we've just built."
	exit 1
	fi

case `file -b $sfread_write_oct_location/sfread.oct` in
	ELF*)
		;;
	Mach*)
		echo "Tests don't work on this platform."
		exit 0
		;;
	*)
		echo "Not able to find the sfread.oct/sfwrite.oct binaries we've just built."
		exit 1
		;;
	esac

# echo "libsndfile_lib_location : $libsndfile_lib_location"
# echo "sfread_write_oct_location : $sfread_write_oct_location"

LD_LIBRARY_PATH="$libsndfile_lib_location:$LD_LIBRARY_PATH"

octave_src_dir=`(cd $octave_src_dir && pwd)`

octave_script="$octave_src_dir/octave_test.m"

(cd $sfread_write_oct_location && octave -qH $octave_script)


