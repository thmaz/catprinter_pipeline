#!/usr/bin/env bash

# kill alles: sudo killall kiod5

# deze werkt als usb bezet is:
# mtp-detect > kijk naar bus x, dev y
# sudo lsof /dev/bus/usb/00x/00y
# vervolgens > sudo kill (pid)

# bluetoothctl voor bluetooth via cli

# MX06 mac address: BC:08:12:15:5A:9B   MX06-08BC

# Usage:printer.py [-h] [-s Time[,XY01[,MacAddress]]] [-c text|image]
#                  [-p flip|fliph|flipv]
#                  [-t Size[,FontFamily][,pf2][,nowrap][,rtl]] [-e 0.0-1.0]
#                  [-q 1-4] [-d] [-u] [-0] [-f XY01] [-m] [-n]
#                  File
#
# Print to Cat Printer Supported models: ('_ZZ00', 'GB01', 'GB02', 'GB03', 'GT01',
# 'MX05', 'MX06', 'MX08', 'MX09', 'MX10', 'YT01')
#
# Positional arguments:
#
#   File                  Path to input file. '-' for stdin
#
# Options:
#
#   -h, --help            Show this help message
#   -s Time[,XY01[,MacAddress]], --scan Time[,XY01[,MacAddress]]
#                         Scan for a printer
#   -c text|image, --convert text|image
#                         Convert input image with ImageMagick
#   -p flip|fliph|flipv, --image flip|fliph|flipv
#                         Image printing options
#   -t Size[,FontFamily][,pf2][,nowrap][,rtl], --text Size[,FontFamily][,pf2][,nowrap][,rtl]
#                         Text printing mode with options
#   -e 0.0-1.0, --energy 0.0-1.0
#                         Control printer thermal strength
#   -q 1-4, --quality 1-4
#                         Print quality
#   -d, --dry             Dry Run: test print process only
#   -u, --unknown         Try to print through an unknown device
#   -0, --0th             No prompt for multiple devices
#   -f XY01, --fake XY01  Virtual run on specified model
#   -m, --dump            Dump Traffic
#   -n, --nothing         Do nothing

# python3 printer.py -u -e 0.0 -q 1 -d -m /home/th0miz/Desktop/vingerafdrukken/test.pbm
# python3 printer.py -e 1.0 -q 4 -d -s 4.0,MX06 -m /home/th0miz/Desktop/vingerafdrukken/test.pbm
# convert

get_unique_filename() {
    local base_name="finger"
    local ext1=".bmp"

    # make variable based on current time
    local timestamp=$(date +"%Y%m%d_%H%M%S")

    #get unique filename
    local unique_filename="${base_name}_${timestamp}${ext1}"

    # variable for format conversion

    #echo pls
    echo "$unique_filename"
}

# variable for format conversion
get_conversion_filename() {
    local base_name="finger"
    local ext2=".pbm"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local conversion_filename="${base_name}_${timestamp}${ext2}"

    echo "$conversion_filename"
}

# Main
while true; do

    unique_filename=$(get_unique_filename)
    conversion_filename=$(get_conversion_filename)

    # delay for getting filename
    sleep 0.05

    echo running getImage.py
    # goto scripts and run getImage.py
    cd ~/Arduino/scripts
    sudo python3 getImage.py /dev/ttyACM1 57600 /home/th0miz/Desktop/vingerafdrukken/"$unique_filename"

    echo converting "$unique_filename" to "$conversion_filename" and resizing to 384pxw

    cd ~/Desktop/vingerafdrukken/

    # Convert itt
    sudo convert "$unique_filename" -resize 384 "$conversion_filename"

    echo moving to printer.py

    # goto printer.py folder
    cd ~/catprinter/Cat-Printer-main

    echo printing "$conversion_filename"

    # run print script
    # e=energy control, q=print quality, seconds, printer type, use the converted files name

    echo PRINTING . . . may take up to a minute
    echo be patient

    python3 printer.py -e 1.0 -q 4 -s 4.0,MX06 /home/th0miz/Desktop/vingerafdrukken/"$conversion_filename"

    sleep 30

done
