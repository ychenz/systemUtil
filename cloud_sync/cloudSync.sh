#!/bin/bash
#cannot sync subdirectory of the cloud
#KDE only
. /home/$USER/Scripts/synapse.env

GFILE_LIST=/tmp/gfilelist.$$.txt
LOG=/tmp/cloudSync.log
ICON=/home/$USER/Scripts/cloud_sync/icon.png
VERSION='Synapse v1.0'

if [[ "$?" != 0 ]];then
	kdialog --passivepopup 'Gdrive connection <font face="verdana" color=red><b>FAILED</b></font>. Cannot connect to cloud :(' --icon $ICON --title "$VERSION" 5
	exit 2
fi

function _help(){
	echo "Usage:"
	echo "    Run without option will sync the folder specified in $SYNC_DIR"
	echo "    -r: Delete old files and resynchronize"
	echo "    -c: Download and recover files from cloud"
	echo "    -h: Show this help message"
	echo "    -g filename: download a specific file"
	
}

#function to download a specific file by name match
function _get(){
	gdrive list 2>>$LOG  1>$GFILE_LIST
	local filename="$1"
	local file_id=$( (cat $GFILE_LIST|grep $filename|awk '{print $1}') )
	if [[ ! -z $file_id ]];then
		cd $DOWNLOAD_PATH
		echo "$file_id"|\
		while read line
		do
			gdrive download -i $file_id
			if [[ $? == 0 ]];then
				echo "$file_id downloaded successful ٩(⁎❛ᴗ❛⁎)۶"
				echo "-----------------">>$LOG
				echo "[$(date +%r)]$file_id downloaded at $DOWNLOAD_PATH">>$LOG
			else
				echo "Download failed °Д°"
			fi
		done
	else
		echo "Well,,$filename is not there:("
	fi
}

function _download(){
	gdrive list 2>>$LOG  1>$GFILE_LIST
	echo "---------------------------------------">>$LOG
	echo "[ $(date +%r) ] Starting download...">>$LOG
	kdialog --passivepopup '<font color=blue>Synapse is downloading backup files to $HOME</font>..' --icon $ICON --title "$VERSION" 5
	local cloud_dir_id=$( (cat $GFILE_LIST|grep $FOLDER|awk '{print $1}'|tr -dc '[:alnum:]') )
	gdrive download -i $cloud_dir_id 1>/dev/null 2>>$LOG
	if [[ "$?" != 0 ]];then
                kdialog --passivepopup 'Download <font face="verdana" color=red><b>FAILED</b></font>:(' --icon $ICON --title "$VERSION" 5
                echo "[ $(date +%r) ] Download of $FOLDER FAILED">>$LOG
                exit 3
	else
		echo "[ $(date +%r) ] Download of $FOLDER finished">>$LOG
	fi
	rm -f $GFILE_LIST
}

function _delete(){
	gdrive list 2>>$LOG  1>$GFILE_LIST
	echo "[ $(date +%r) ] !!Resynchronizing...">>$LOG
	kdialog --passivepopup '<font color=blue>Deleting and re-uploading</font>..' --icon $ICON --title "$VERSION" 5
	local cloud_dir_id=$( (cat $GFILE_LIST|grep $FOLDER|awk '{print $1}'|tr -dc '[:alnum:]') )

	if [[ ! -z $cloud_dir_id ]];then
		gdrive delete -i $cloud_dir_id >/dev/null 2>&1
		if [[ "$?" != 0 ]];then
			kdialog --passivepopup 'Deletion <font face="verdana" color=red><b>FAILED</b></font>:(' --icon $ICON --title "$VERSION" 5
			echo "[ $(date +%r) ] Deletion of $FOLDER FAILED">>$LOG
			exit 2
		else
			echo "[ $(date +%r) ] Deletion of $FOLDER finished">>$LOG
		fi
	else
		echo "[ $(date +%r) ] No Folder Found to delete">>$LOG
	fi
	
	gdrive folder -t "$FOLDER"  >/dev/null 2>&1
        if [[ "$?" != 0 ]];then
                echo "[ $(date +%r) ] ***Folder $FOLDER FAILED to create">>$LOG
                kdialog --passivepopup "Creating cloud folder: $FOLDER <font face="verdana" color=red><b>FAILED</b></font>.:(" --icon $ICON --title "$VERSION" 5 2>>$LOG
		exit 2
        else
                echo "[ $(date +%r) ] Folder $cloud_dir created">>$LOG 
        fi
	
}

#function to upload files recursively from a folder, gdrive seems not support folder upload
function _upload(){

	local file_name="$1"  #absolute path
	local cloud_parent_id=$2
	local file_raw_name=$( (echo "$file_name"|awk -F\/ '{print $NF}'|awk -F\" '{print $1}') ) #stripe the absolute path,$NF is the # of field
	if [[ $DEBUG == 1 ]];then
		echo ""
		echo "        In the upload"
		echo "        BEFORE: file_name:$file_name file_raw_name:$file_raw_name"
	fi

	if [[ -d $file_name ]];then
		gdrive folder -t "$file_raw_name" -p "$cloud_parent_id" >/dev/null 2>&1
		if [[ "$?" != 0 ]];then
			echo "[ $(date +%r) ] ***Folder $cloud_dir FAILED to create">>$LOG		
                        kdialog --passivepopup "Creating cloud folder: $cloud_dir <font face="verdana" color=red><b>FAILED</b></font>:(" --icon $ICON --title "$VERSION" 5 2>>$LOG
			exit 2
		else
			echo "[ $(date +%r) ] Folder $file_raw_name created">>$LOG		
                fi

		gdrive list 2>>$LOG  1>$GFILE_LIST                                                                   #refresh list
		local new_folder_id=$( (cat $GFILE_LIST|grep "$file_raw_name"|awk '{print $1}'|tr -dc '[:alnum:]') ) #get new folder id
		local child_files=$( (ls -b "$file_name") )
		if [[ $DEBUG == 1 ]];then 
			echo "Uploading folder $file_name..."
			echo "\n    FILES IN SUBFOLDER: $child_files"
		fi

		echo "$child_files"|\
		while read file	 			      
		do
			if [[ $DEBUG == 1 ]];then echo "            Entering upload func for $file_name/$file:";fi
			_upload $( (echo "$file_name/$file"|sed 's/ /\\ /g') ) $new_folder_id                #recursive upload
		done
	else
		if [[ $DEBUG == 1 ]];then 
			echo "        Uploading $file_name as $file_raw_name"
			echo "        PARA: filename:$file_name id: $cloud_parent_id title:$file_raw_name"
		fi

		gdrive upload -f "$file_name" -p "$cloud_parent_id" -t "$file_raw_name" >/dev/null 2>&1

		if [[ "$?" != 0 ]];then
		        kdialog --passivepopup "Uploading $file_name <font face="verdana" color=red><b>FAILED</b></font>X_X" --icon $ICON --title "$VERSION" 5 2>>$LOG
			echo "[ $(date +%r) ] ***$file_name FAILED to upload">>$LOG
		else
			echo "[ $(date +%r) ] $file_name uploaded">>$LOG
		fi

	fi
}


while getopts ":rhcg:" opt; do
  case $opt in
    r)
	_delete
	;;
    c)
	_download
	exit 0
	;;
    h)
	_help
	exit 0
      ;;
    g)
	_get $OPTARG
	exit 0
	;;
    :)
	echo "Option -$OPTARG requires an argument." >&2
      	exit 1
      	;;
    \?)
	echo "Invalid option: -$OPTARG" >&2
	echo ""
	_help
	exit 1
      ;;
  esac
done

kdialog --passivepopup '<font color=blue>Synapse is synchronizing files</font>(•ω•)' --icon $ICON --title "$VERSION" 5

echo "----------------------------------">>$LOG
echo "[$(date)] Cloud sync started... ">>$LOG
gdrive list 2>>$LOG  1>$GFILE_LIST
FOLDER_ID=$( (cat $GFILE_LIST|grep $FOLDER|awk '{print $1}'|tr -dc '[:alnum:]') )

if [[ -z $( (cat $GFILE_LIST|grep "package_tree.$(date +%Y%m%d).txt") ) ]];then
	echo "Backing up yum package tree...">>$LOG
	rpm -qa|gdrive upload -s -t "package_tree.$(date +%Y%m%d).txt" -p $FOLDER_ID >/dev/null 2>&1
fi

cat "$SYNC_DIR"|\
while read dir
do
	local_dir=$( (echo $dir|awk -F, '{print $1}') ) #get local dir
	cloud_dir=$( (echo $dir|awk -F, '{print $2}') ) #get dezired cloud dir name
	cloud_record=$( (cat $GFILE_LIST|grep $cloud_dir) ) #use to check if folder exists
	kdialog --passivepopup "Synchronizing files to $cloud_dir ..." --icon $ICON --title "$VERSION" 5

	if [[ $DEBUG == 1 ]];then echo "For $local_dir to $cloud_dir:";fi

	#check cloud dir
	if [[ -z $cloud_record ]];then
		echo "[ $(date +%r) ] $cloud_dir not exists for $local_dir. Uploading...">>$LOG

		kdialog --passivepopup "Creating cloud folder $cloud_dir .(╯°□°）" --icon $ICON --title "$VERSION" 5 2>>$LOG
		gdrive folder -t "$cloud_dir" -p $FOLDER_ID >/dev/null 2>&1

		if [[ "$?" != 0 ]];then
			echo "[ $(date +%r) ] ***Folder $cloud_dir FAILED to create">>$LOG		
                        kdialog --passivepopup "Creating cloud folder: $cloud_dir <font face="verdana" color=red><b>FAILED</b></font>\(\`Д\´\)" --icon $ICON --title "$VERSION" 5 2>>$LOG
			exit 2
		else
			echo "[ $(date +%r) ] Folder $cloud_dir created">>$LOG		
                fi

		gdrive list 2>>$LOG  1>$GFILE_LIST #refresh list
	fi
	
	#sync files in each folder


	cloud_dir_id=$( (cat $GFILE_LIST|grep $cloud_dir|awk '{print $1}'|tr -dc '[:alnum:]') )

	##start of sync
	ls -b $local_dir
	files=$( (ls -b $local_dir) )
	echo "$files"|\
	while read file
	do
		file_record=$( (cat $GFILE_LIST|grep "$file") )
		
		if [[ -z $file_record ]];then
			echo "    [ $(date +%r) ] Uploading $file to $cloud_dir...">>$LOG

			if [[ $DEBUG == 1 ]];then
				echo ""
				echo "    [ $(date +%r) ] Uploading $file to $cloud_dir..."
                        	echo "    Entering upload func for $local_dir/$file:"
                        	echo "    $local_dir/$file"
			fi
			_upload $( (echo "$local_dir/$file"|sed 's/ /\\ /g') ) $cloud_dir_id
		fi
	done
done
kdialog --passivepopup 'Synchronization <font color=green>completed</font><font color=red>☀</font>' --icon $ICON --title "$VERSION" 5 2>>$LOG
rm -f $GFILE_LIST
