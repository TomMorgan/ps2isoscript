# ps2isoscript
A bash script for dealing with PlayStation2 ISO files using Redump

PS2 ISO Script version 1.0
Usage: ps2isotool.sh options File1 [File2] [File 3]...
NOTE: Run 'ps2isotool.sh -g' to get a Redump DAT before you do anything
Options: 
 -a Rename files based on CRC32 from Redump DAT
 -b Rename files based on MD5 sum from Redump DAT
 -c Rename files based on SHA1 hash from Redump DAT
 -d Output serial number for file if present
 -e Prepend serial number onto file if present
 -f Remove serial from filenames if present
 -g Download and update Redump DAT (stored in ~/.config)
 -h Truncate filenames to 32 characters
 -i Use BINChunker to turn CUE files supplied into ISO files (Requires BINChunker,
    usually available as a package called 'bchunk' from most distros repos) 
    Note that any ISO files created from -i will not be operated on by other
    commands in this script unless it is run a second time. This may change
    in a new version
 
 If anyone wants to update or fix a bug or add new features to this script, go ahead.
