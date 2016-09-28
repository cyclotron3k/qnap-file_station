Qnap::FileStation
=======

This gem provides an interface to the File Station app that comes installed by default on many QNAP NAS.

It provides access to all available endpoints, but the documentation is patchy and untested. Use with caution.

Installation
-------

`gem install qnap-file_station`

Usage
-------

```ruby
require 'qnap/file_station'

fs = Qnap::FileStation.new '192.168.1.100', 'username', 'password'
fs.createdir dest_folder: "", dest_path: ""
contents = fs.get_extract_list extract_file: "my_zip_file.zip"
fs.logout
```

```ruby
# Alternative syntax to guarantee logout

Qnap::FileStation.session('192.168.1.100', 'username', 'password') do |fs|
	# Show contents of the recycle bin
	pp fs.get_tree node: "recycle_root"
	# logout is automatically called, even if there was an exception
end

```

Available methods

### createdir
Create a folder in the specified path.

#### Parameters
Key | Description
--- | ---
dest_folder | Folder name
dest_path | Path of the folder

### rename
Rename a folder or file in the specified path.

#### Parameters
Key | Description
--- | ---
sid | Input sid for authentication
path | Path of the folder/ file
source_name | Current folder/ file name to be changed
dest_name | New folder/ file name

### copy
Copy a file/folder from the source to the destination.

#### Parameters
Key | Description
--- | ---
source_file | Name of the copied file/folder
source_total | Total number of copied files/folders
source_path | Source path of the copied file/folder
dest_path | Destination of the copied file/folder
mode | 1: skip, 0: overwrite
dup | The duplication file name when copying the same destination with source files/folders.

### move
Move a file/folder from the source to the destination.

#### Parameters
Key | Description
--- | ---
source_file | Name of the copied file/folder
source_total | Total number of copied files/folders
source_path | Source path of the copied file/folder
dest_path | Destination of the copied file/folder
mode | 1: skip, 0: overwrite

### get_extract_list
List the content of a zipped file.

#### Parameters
Key | Description
--- | ---
extract_file | Path of the extracted file
code_page | Extracting code page (UTF-8 only)
start | Start number of the listed contents
limit | Total number of the listed contents
sort | Sorting type (filename, file_size, compress_size, mt)
dir | List type (ASC, DESC)

### extract
Extract files from a zipped file to the specified path on NAS. This is an asynchronous API. The caller can use the returned process ID (pid) for further operations.

#### Parameters
Key | Description
--- | ---
extract_file | Path of the extracted files
code_page | Extracting code page (UTF-8 only)
dest_path | Destination of the extracted files
pwd | Extraction password (can be null)
mode | Extraction mode (extract_all, extract_part)
overwrite | 1: overwrite, 0: skip
path_mode | full: extract file with full path none: don't extract file with full path
code_page | Extracting code page (UTF-8 only) If mode is extract_part
part_file | Name of the file to be extracted (can be more than one)
part_total | The total number of extracted files

### cancel_extract
Cancel the extraction process by process ID.

#### Parameters
Key | Description
--- | ---
pid | Pid of the extracting process

### compress
Compress files to a specified file on NAS. This is an asynchronous API. The caller can use the returned process ID (pid) for further operations.

#### Parameters
Key | Description
--- | ---
extract_file | Path of the extracted files
compress_name | The compressed name
type | Compressed format type (7z/zip)(default:zip)
pwd | The compressed password (can be null)
level | Compressed level (normal/large/fast) (default:normal)
encryipt | 7z:AES256, zip:ZipCrypto/AES256 (can be null)
path | The compressed file path
total | The amount of compression files number
compress_file | The compressed file name

### cancel_compress
Cancel the compressing process by process ID.

#### Parameters
Key | Description
--- | ---
pid | Pid of the compressing process

### get_compress_status
Get the compressing status by process ID.

#### Parameters
Key | Description
--- | ---
pid | Pid of the compressing process

### download
Download a file, a folder, or multiple files as a zip file, a compressed file, or just the same as they are.

#### Parameters
Key | Description
--- | ---
isfolder | The request file is a folder. 1: yes, 0: no.
compress | If the request file is a folder or files then<br>0/1: zip archive only, 2: compress files.<br>else the request file is a single file then<br>0: transfer the original file to client<br>1: zip archive only<br>2: compress files<br>
source_path | Path of the file. Start with the share name.
source_file | File name.
source_total | Total number of files.

### get_thumb
Get a size-specified thumbnail of an image file.

#### Parameters
Key | Description
--- | ---
path | Path of the file. Start with the share name.
name | File name.
size | 80/320/640; default value:320

### upload
Upload a file.

#### Parameters
Key | Description
--- | ---
type | standard
dest_path | Destination dir path
overwrite | 1: overwrite, 0: skip
progress | Destination file path, "/" needs to be replaced with "-"

### get_viewer
Open a multimedia file stream for viewing or playing.

#### Parameters
Key | Description
--- | ---
func | open
source_path | Source dir path
source_file | Source file name
player | Use the
rtt | 1:FLV for video or music, 3:MP3 for music
format | Video transcode format type for opening. jwplayer player or not (1/0)
format | can be : mp4_360 / mp4_720 / flv_720

### get_tree
Get folder list in a folder, a shared iso, the shared root folder, or the recycle bin.

#### Parameters
Key | Description
--- | ---
is_iso | Is a iso share. 1: yes, 0: no. Default is 0. This value is according to a field "iconCls" in get_tree response. If "iconCls" is "iso", this value is 1.
node | Target folder path. Use folder path to get folder list, and use the value with "share_root" to get share list, or use the value with "recycle_root" to get recycle bin share list.

### get_list
Retrieve both file and folder list in a specified folder or a shared iso, with filters such as response record count, file type..., etc.

#### Parameters
Key | Description
--- | ---
is_iso | Is a iso share. 1: yes, 0: no
list_mode | Value is "all"
path | Folder path
dir | Sorting direction. ASC: Ascending , DESC: Descending
limit | Number of response datas
sort | Sort field (filename/filesize/filetype/mt/privilege/owner/group)
start | Response data start index
hidden_file | List hidden file or not. 0:donnot list hidden files, 1:list files
type | 1: MUSIC, 2:VIDEO, 3:PHOTO (1/2/3)
mp4_360 | Video format type mp4_360 true or not(1/0)
mp4_720 | Video format type mp4_720 true or not(1/0)
flv_720 | Video format type flv_720 true or not(1/0)
filename | Search video file name

### get_file_size
Get total files size in a specified path. The size counting includes hidden file and folder.

#### Parameters
Key | Description
--- | ---
path | Folder path
total | The number of file/folder which are calculating the total size
name | file or folder name

### delete
Delete folder(s)/file(s) in a specified path.

#### Parameters
Key | Description
--- | ---
path | Folder path.
file_total | Total number of folder/file(s).
file_name | Folder/file name.

### stat
Get status of folder(s)/file(s), such as file size, privilege..., etc.

#### Parameters
Key | Description
--- | ---
path | Folder path.
file_total | Total number of folder/file(s).
file_name | Folder/file name.

### stat 
Set folder(s)/file(s) modification time.

#### Parameters
Key | Description
--- | ---
path | Folder path.
file_total | Total number of folder/file(s).
file_name | Folder/file name.
settime | 1: set modification time
timestamp | Epoch time (seconds since 1970-01-01 00:00:00 UTC).<br>The modification time will be set current datetime on the server if not specified.

### search
Search file/folder by key word within a specified path.

#### Parameters
Key | Description
--- | ---
is_iso | Is a iso share. 1: yes, 0: no
keyword | keyword
source_path | Folder path
dir | Sorting direction. ASC: Ascending , DESC: Descending
limit | Number of response data
sort | Sort field (filename/filesize/filetype/mt/privilege/owner/group)
start | Response data start index

### 
Download a shared file by an unique ID (ssid).

#### Parameters
Key | Description
--- | ---
uniqe_id | Use the unique id to download the shared file.

### get_share_link
Create share links of specified files, and retrieve or email the links to someone.

#### Parameters
Key | Description
--- | ---
network_type | internet: from network, local: from local
download_type | create_download_link: create download link, email_download_link: email download link
valid_duration | specific_time: specific the download time, period_of_time: time period, forever: forver download load
hostname | host IP or domain name
day | shared day time if valid_duration=period_of_time
hour | shared hour time if valid_duration=period_of_time
file_total | shared datetime if valid_duration=specific_time
file_name | 0(zero) if valid_duration=forever
path | download file path
ssl | enabled ssl
access_enabled | enable access code
access_code | access code
include_access_code | email contents include access code or not
addressee | get email addressee
subject | get email subject
content | get email content

### share_file
Create share link and email to someone.

#### Parameters
Key | Description
--- | ---
network_type | internet: from network, local: from local
download_type | create_download_link: create download link, email_download_link: email download link
valid_duration | specific_time: specific the download time, period_of_time: time period, forever: forver download load
hostname | host IP or domain name
day | shared day time if valid_duration=period_of_time
hour | shared hour time if valid_duration=period_of_time
file_total | shared datetime if valid_duration=specific_time
file_name | 0(zero) if valid_duration=forever
path | download file path
ssl | enabled ssl
access_enabled | enable access code
access_code | access code
include_access_code | email contents include access code or not
addressee | get email addressee
subject | get email subject
content | get email content
link_url | internet: from network, local: from local
mail_content_date | mail contents for valid date information
mail_content_pwd | mail contents for password information
expire_time | expire time(seconds)

### get_share_list
Get whole shared file list.

#### Parameters
Key | Description
--- | ---
dir | Sorting direction. ASC: Ascending , DESC: Descending
limit | Number of response data
sort | Sort field (filename/filesize/filetype/mt/privilege/owner/group)
start | Response data start index

### get_domain_ip_list
Get hostname and external IP address of the NAS.


### delete_share
Stop specified file(s) sharing.

#### Parameters
Key | Description
--- | ---
file_total | number of total files
download_link | link url
filename | shared file

### delete_share_all
Stop all file sharing.


### update_share_link
Update the attributes of specified share links.

#### Parameters
Key | Description
--- | ---
download_type | create_download_link: create download link, email_download_link: email download link
valid_duration | specific_time: specific the download time,<br>period_of_time: time period,<br>forever: forver download load
hostname | host IP or domain name
datetime | expire sharing time
file_total | shared datetime if valid_duration=specific_time
ssl | enabled ssl
access_enabled | enable access code
access_code | access code
ssids | the ssid of shared files

### get_tree
Retrieve recycle bin tree list. 2

#### Parameters
Key | Description
--- | ---
node | Recycle Bin node name (${node}=recycle_root)

### trash_recovery
Recovery specified files in recycle bin. This is an asynchronous API. The caller can use the returned process ID (pid) for further operations.

#### Parameters
Key | Description
--- | ---
source_file | Name of the copied file/folder
source_total | Total number of the recovery trash files
source_path | Source path of the trash
mode | 1: skip, 0: overwrite
source_file | trash file
source_file | ....

### cancel_trash_recovery
Cancel recycle bin recovery process by process ID.

#### Parameters
Key | Description
--- | ---
pid | Pid of the recycle bin recovery process

### delete
Empty the recycle bin.

#### Parameters
Key | Description
--- | ---
path | The path folder name of recycle bin
file_name | Same as the value ${path}

### video_ml_queue
Retrieve the status of media library transcoding queue.

#### Parameters
Key | Description
--- | ---
op | 1: transcoding queue lists
subop | 0: wait status<br>1: finish status<br>2: error<br>3: ongoing<br>4: all

### video_ml_queue
Add or delete files in the media library transcoding queue.

#### Parameters
Key | Description
--- | ---
op | Operation
subop | Sub-operation
total | The amount of filenames.
path | The opration path name.
filename | filename

### video_list
Get media library transcode files list.

#### Parameters
Key | Description
--- | ---
source_path | Source file path
source_total | The source file total number for ${source_file}
source_file | Source file name

### video_ml_status
Get media library files transcode status.

#### Parameters
Key | Description
--- | ---
path | Source file path
total | The source file total number for ${source_file}
filename | Source file name

### delete_transcode
Delete the media transcode or image files.

#### Parameters
Key | Description
--- | ---
path | Folder path.
file_total | Total number of folder/file(s).
file_name | Folder/file name.
mode | 1: delete image files<br>2: delete transcode video files<br>3: delete image and transcode video files.
keep_trans | 0: delete transcode files in "@Transcode" folder<br>1: do not delete transcode files in "@Transcode" folder

### get_video_qstatus
Get transcode file status.

#### Parameters
Key | Description
--- | ---
pid | Video transcoding process id.

### cancel_transcode
Cancel transcoding process.

#### Parameters
Key | Description
--- | ---
pid | Video transcoding process id.
