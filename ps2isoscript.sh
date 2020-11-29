#! /bin/bash

set -m

RedumpURL="http://redump.org/datfile/ps2"
RedumpZip="$HOME/redumpdat.zip"
DatFile="$HOME/redumpps2.dat"
NewFilename=${!#}
CmdLines=( "$@" )
RenameFlag=0

if [ "$#" -eq 0 ]
then
   echo "PS2 ISO Script version 1.0"
   echo "Usage: ps2isotool.sh options File1 [File2] [File 3]..."
   echo "NOTE: Run 'ps2isotool.sh -g' to get a Redump DAT before you do anything" 
   echo "Options: "
   echo " -a Rename files based on CRC32 from Redump DAT"
   echo " -b Rename files based on MD5 sum from Redump DAT"
   echo " -c Rename files based on SHA1 hash from Redump DAT"
   echo " -d Output serial number for file if present"
   echo " -e Prepend serial number onto file if present"
   echo " -f Remove serial from filenames if present"
   echo " -g Download and update Redump DAT (stored in ~/.config)"
   echo " -h Truncate filenames to 32 characters"
   echo " -i Use BINChunker to turn CUE files supplied into ISO files (Requires BINChunker,"
   echo "    usually available as a package called 'bchunk' from most distros repos) "
   echo "    Note that any ISO files created from -i will not be operated on by other" 
   echo "    commands in this script unless it is run a second time. This may change"
   echo "    in a new version"
   echo " "
   echo " If anyone wants to update or fix a bug or add new features to this script, go ahead."
fi

for i in "$@"; do

	if [[ "${1:0:1}" == "-" ]]; 
	then
      	   CmdStr=$i

           if [[ "$CmdStr" == "-g" ]];
           then
#              if [ ! -d "$HOME/.config/" ]
#              then
#                 mkdir "$HOME/.config/"
#              fi

             wget -O "$RedumpZip" "$RedumpURL"
             unzip "$RedumpZip" -d "$HOME/.config"

             mv -f "$HOME/.config/$(unzip -l "$RedumpZip" | sed '1,3d; /---------                     -------/d; $d'|cut -c31-)" "$DatFile"
             rm "$RedumpZip"

              echo "Redump DAT updated!"
              
      
           fi

           for ((k=0; k<$#; k++));
           do

	           if [ -f "${CmdLines[k]}" ]
                   then  
      		   
		   case "$CmdStr" in

	      	      "-a")
                      
                      if [ -f "$DatFile" ]
                      then

	                 crc32 "${CmdLines[k]}">/tmp/tempry
	                 NewFilename=$(printf "$(xmllint --xpath //rom[@crc="'$(cat tempry)'"]/@name $DatFile | tail -c +8 | head -c -1)")      
        	         rm /tmp/tempry
                         RenameFlag=1
                         echo "$NewFilename"
                      
                      else

                         echo "Redump DAT can't be found! Run script with "-g" option to download latest DAT file." 
                      
                      fi
                      ;;
     
               	      "-b")
               
                      if [ -f "$DatFile" ]
                      then
 
                         NewFilename=$(printf "$(xmllint --xpath //rom[@md5="'$(md5sum "${CmdLines[k]}" | head -c 32)'"]/@name $DatFile | tail -c +8 | head -c -1)")
  	                 RenameFlag=1
                         echo "NewFilename"
                      
                      else

                      echo "Redump DAT can't be found! Run script with "-g" option to download latest DAT file."
                      
                      fi
                      ;;

                      "-c")
                      
                      if [ -f "$DatFile" ]
                      then
                   
                         NewFilename=$(printf "$(xmllint --xpath //rom[@sha1="'$(sha1sum "${CmdLines[k]}" | head -c 40)'"]/@name $DatFile | tail -c +8 | head -c -1)")
                         RenameFlag=1
                         echo "NewFilename"
                      
                      else

                         echo "Redump DAT can't be found! Run script with "-g" option to download latest DAT file."

                      fi
                      ;;

                      "-d")

                      LABEL=$(isoinfo -f -i "${CmdLines[k]}" | grep -E "[Ss][LlCc][AaCcEePpJjKkUu][DdMmSsTtXx]_???.??" | head -c 12 | tail -c 11)
                      LABEL=${LABEL^^}
                      printf "$LABEL\n"


	              ;;

                      "-e")

                      LABEL=$(isoinfo -f -i "${CmdLines[k]}" | grep -E "[Ss][LlCc][AaCcEePpJjKkUu][DdMmSsTtXx]_???.??" | head -c 12 | tail -c 11)
                      LABEL=${LABEL^^}
 
             
                      if [ "$LABEL" != "" ]
                      then 
                         NewFilename=$LABEL.$(printf "$(basename "${CmdLines[k]}")")
                         RenameFlag=1
                      fi
                      ;;


                      "-f")

                      #Remove serial if there
               
         	      LABEL=$(isoinfo -f -i "${CmdLines[k]}" | grep -E "[Ss][LlCc][AaCcEePpJjKkUu][DdMmSsTtXx]_???.??" | head -c 12 | tail -c 11)
		      LABEL=${LABEL^^}

		      if [ "$LABEL" == "$(basename "${CmdLines[k]}" | head -c 11)" ]
		      then

		     	  NewFilename=$(printf "$(basename "${CmdLines[k]}" | tail -c +13)")

		      fi
                    
                      echo "New filename is $NewFilename"

                      RenameFlag=1

                      ;;
 
                     "-h")
                     
                      FileBaseName=$(basename "${CmdLines[k]}")
                      
                      if [ "$(printf "$FileBaseName" | tail -c 3)" == "iso" ]  
                      then
                         if [ ${#FileBaseName} -ge 32 ]
		         then
	                      TRUNCATED=$(printf "$FileBaseName" | head -c 28)
        	              EXTENSION=$(printf "$FileBaseName" | tail -c 4)
                      
                	      RenameFlag=1
                      
                              NewFilename=$(printf "$TRUNCATED$EXTENSION")
                       
                              echo "New filename is $NewFilename"
		         fi
                      fi
                      ;;
                      
                      "-i")

                       for CueFile in "${CmdLines[k]}" ;
                       do
                          if ! command -v bchunk &>/dev/null
                          then 
                             echo "Install BINChunker (bchunk) for converting BIN/CUE to ISO."
                          else
                             if [ -f "$(printf "$CueFile" | head -c -4 && printf '.bin')" ]
                             then
                                bchunk "$(printf "$CueFile" | head -c -4 && printf '.bin')" "$CueFile" "$(printf "$CueFile" | head -c -4)"
                                if ! compgen -G "./$(printf "$CueFile" | head -c -4 && printf '02')"* > /dev/null; then

                                   mv "$(printf "$CueFile" | head -c -4 && printf '01.iso')" "$(printf "$CueFile" | head -c -4 && printf '.iso')"

                                fi
                             fi
                          fi
                      done 

                      ;;

                  esac

 	                  if [ $RenameFlag -eq 1 -a ${#NewFilename} -ge 1 ]
        	          then

                	  	mv "$(realpath "${CmdLines[k]}")" "$(dirname "${CmdLines[k]}")/$NewFilename"

                  	  	CmdLines[k]="$(dirname "${CmdLines[k]}")/$NewFilename"
                                NewFilename=
                          fi

                          RenameFlag=0
                  fi      
         
         done
         
         fi
         
        

done   
