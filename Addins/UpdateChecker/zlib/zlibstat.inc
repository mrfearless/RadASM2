; zlibstat.lib PROTOTYPES
; ~~~~~~~~~~~~~~~~~~~~~~~

adler32 PROTO :DWORD,:DWORD,:DWORD
compress PROTO :DWORD,:DWORD,:DWORD,:DWORD
compress2 PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
crc32 PROTO :DWORD,:DWORD,:DWORD
deflate PROTO :DWORD,:DWORD
deflateCopy PROTO :DWORD,:DWORD
deflateEnd PROTO :DWORD
deflateInit2_ PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
deflateInit_ PROTO :DWORD,:DWORD,:DWORD,:DWORD
deflateParams PROTO :DWORD,:DWORD,:DWORD
deflateReset PROTO :DWORD
deflateSetDictionary PROTO :DWORD,:DWORD,:DWORD
fclose_file_func PROTO :DWORD,:DWORD
ferror_file_func PROTO :DWORD,:DWORD
fopen_file_func PROTO :DWORD,:DWORD,:DWORD
fread_file_func PROTO :DWORD,:DWORD,:DWORD,:DWORD
fseek_file_func PROTO :DWORD,:DWORD,:DWORD,:DWORD
ftell_file_func PROTO :DWORD,:DWORD
fwrite_file_func PROTO :DWORD,:DWORD,:DWORD,:DWORD
get_crc_table PROTO

; WARNING!!!
; Gz functions supported but in order to use them you should link with  C runtime libraries

gzclose PROTO :DWORD
gzdopen PROTO :DWORD,:DWORD
gzeof PROTO :DWORD
gzerror PROTO :DWORD,:DWORD
gzflush PROTO :DWORD,:DWORD
gzgetc PROTO :DWORD
gzgets PROTO :DWORD,:DWORD,:DWORD
gzopen PROTO :DWORD,:DWORD
gzputc PROTO :DWORD,:DWORD
gzputs PROTO :DWORD,:DWORD
gzread PROTO :DWORD,:DWORD,:DWORD
gzrewind PROTO :DWORD
gzseek PROTO :DWORD,:DWORD,:DWORD
gzsetparams PROTO :DWORD,:DWORD,:DWORD
gztell PROTO :DWORD
gzwrite PROTO :DWORD,:DWORD,:DWORD


inflate PROTO :DWORD,:DWORD
inflateEnd PROTO :DWORD
inflateInit2_ PROTO :DWORD,:DWORD,:DWORD,:DWORD
inflateInit_ PROTO :DWORD,:DWORD,:DWORD
inflateReset PROTO :DWORD
inflateSetDictionary PROTO :DWORD,:DWORD,:DWORD
inflateSync PROTO :DWORD
inflateSyncPoint PROTO :DWORD
uncompress PROTO :DWORD,:DWORD,:DWORD,:DWORD
unzClose PROTO :DWORD
unzCloseCurrentFile PROTO :DWORD
unzGetCurrentFileInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
unzGetGlobalComment PROTO :DWORD,:DWORD,:DWORD
unzGetGlobalInfo PROTO :DWORD,:DWORD
unzGetLocalExtrafield PROTO :DWORD,:DWORD,:DWORD
unzGoToFirstFile PROTO :DWORD
unzGoToNextFile PROTO :DWORD
unzLocateFile PROTO :DWORD,:DWORD,:DWORD
unzOpen PROTO :DWORD
unzOpen2 PROTO :DWORD,:DWORD
unzOpenCurrentFile PROTO :DWORD
unzOpenCurrentFile2 PROTO :DWORD,:DWORD,:DWORD,:DWORD
unzReadCurrentFile PROTO :DWORD,:DWORD,:DWORD
unzStringFileNameCompare PROTO :DWORD,:DWORD,:DWORD
unzeof PROTO :DWORD
unztell PROTO :DWORD
zError PROTO :DWORD
zipClose PROTO :DWORD,:DWORD
zipCloseFileInZip PROTO :DWORD
zipCloseFileInZipRaw PROTO :DWORD,:DWORD,:DWORD
zipOpen PROTO :DWORD,:DWORD
zipOpen2 PROTO :DWORD,:DWORD,:DWORD,:DWORD
zipOpenNewFileInZip PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
zipOpenNewFileInZip2 PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
zipWriteInFileInZip PROTO :DWORD,:DWORD,:DWORD
zlibVersion PROTO

;--------------------Structures-----------------------------
;internal_state		STRUCT 
;dummy		DWORD		?
;internal_state		ENDS

zlib_filefunc_def		STRUCT 
zopen_file		DWORD		?
zread_file		DWORD		?
zwrite_file		DWORD		?
ztell_file		DWORD		?
zseek_file		DWORD		?
zclose_file		DWORD		?
zerror_file		DWORD		?
opaque		DWORD		?
zlib_filefunc_def		ENDS


linkedlist_datablock_internal		STRUCT
next_datablock		DWORD	? ;PTR linkedlist_datablock_internal
avail_in_this_block	DWORD		?
filled_in_this_block	DWORD		?
unused		DWORD	?
data		BYTE	4080t DUP (?)
linkedlist_datablock_internal		ENDS


linkedlist_data		STRUCT 
first_block		DWORD		? ;linkedlist_datablock_internal
last_block		DWORD		? ;linkedlist_datablock_internal
linkedlist_data		ENDS


z_stream		STRUCT
next_in		DWORD ?
avail_in	DWORD ?
total_in	DWORD ?
next_out	DWORD ?
avail_out	DWORD ?
total_out	DWORD ?
msg			DWORD ?
state		DWORD ?
zalloc		DWORD ?
zfree		DWORD ?
opaque		DWORD ?
data_type	DWORD ?
adler		DWORD ?
reserved	DWORD ?
z_stream		ENDS


curfile_info		STRUCT
stream		z_stream		<>
stream_initialised	SDWORD		?
pos_in_buffered_data	DWORD		?
pos_local_header	DWORD		?
central_header		DWORD		?
size_centralheader	DWORD		?
flag		DWORD		?
method		SDWORD		?
raw		SDWORD		?
buffered_data	Byte		16384t DUP (?)
dosDate		DWORD		?
crc32		DWORD		?
curfile_info		ENDS

zip_internal		STRUCT
z_filefunc		zlib_filefunc_def		<>
filestream		DWORD		?
central_dir		linkedlist_data		<>
in_opened_file_inzip	DWORD		?
ci		curfile_info		<>
begin_pos	DWORD		?
number_entry	DWORD		?
zip_internal	ENDS



tm_zip	STRUCT
tm_sec	DWORD	?
tm_min	DWORD	?
tm_hour	DWORD	?
tm_mday	DWORD	?
tm_mon	DWORD	?
tm_year	DWORD	?
tm_zip	ENDS

zip_fileinfo Struct
tmz_date	tm_zip		<>
dosDate		DWORD		?
iflag		DWORD		?
eflag		DWORD		?
zip_fileinfo ENDS

;-----------------Unzip Structures-----------------------------
tm_unz		STRUCT
tm_sec		DWORD		?
tm_min		DWORD		?
tm_hour		DWORD		?
tm_mday		DWORD		?
tm_mon		DWORD		?
tm_year		DWORD		?
tm_unz		ENDS

unz_global_info		STRUCT
number_entry		DWORD		?
size_comment		DWORD		?
unz_global_info		ENDS

unz_file_info		STRUCT
version			DWORD		?
version_needed	DWORD		?
flag			DWORD		?
compression_method	DWORD		?
dosDate				DWORD		?
crc					DWORD		?
compressed_size		DWORD		?
uncompressed_size	DWORD		?
size_filename		DWORD		?
size_file_extra		DWORD		?
size_file_comment	DWORD		?
disk_num_start		DWORD		?
internal_fa			DWORD		?
external_fa			DWORD		?
tmu_date			tm_unz		<>
unz_file_info		ENDS

unz_file_info_internal		STRUCT
offset_curfile		DWORD		?
unz_file_info_internal		ENDS

file_in_zip_read_info		STRUCT
read_buffer					DWORD		?
stream						z_stream		<>
pos_in_zipfile				DWORD		?
stream_initialised			DWORD		?
offset_local_extrafield		DWORD		?
size_local_extrafield		DWORD		?
pos_local_extrafield		DWORD		?
crc32						DWORD		?
crc32_wait					DWORD		?
rest_read_compressed		DWORD		?
rest_read_uncompressed		DWORD		?
z_filefunc					zlib_filefunc_def		<>
filestream					DWORD		?
compression_method			DWORD		?
byte_before_the_zipfile		DWORD		?
raw							DWORD		?
file_in_zip_read_info		ENDS


unz_s		STRUCT
z_filefunc		zlib_filefunc_def		<>
filestream		DWORD		?
gi		unz_global_info		<>
byte_before_the_zipfile		DWORD		?
num_file		DWORD		?
pos_in_central_dir	DWORD		?
current_file_ok		DWORD		?
central_pos		DWORD		?
size_central_dir	DWORD		?
offset_central_dir	DWORD		?
cur_file_info		unz_file_info		<>
cur_file_info_internal	unz_file_info_internal		<>
pfile_in_zip_read	DWORD		?
unz_s		ENDS



;----------------------------------EQU----------------------------
ZIP_OK		EQU		000000000h
ZIP_ERRNO		EQU		0ffffffffh
ZIP_PARAMERROR		EQU		0ffffff9ah
ZIP_INTERNALERROR		EQU		0ffffff98h
;----------------------------------------------------------------
UNZ_OK		EQU		000000000h
UNZ_END_OF_LIST_OF_FILE		EQU		0ffffff9ch
UNZ_ERRNO		EQU		0ffffffffh
UNZ_EOF		EQU		000000000h
UNZ_PARAMERROR		EQU		0ffffff9ah
UNZ_BADZIPFILE		EQU		0ffffff99h
UNZ_INTERNALERROR		EQU		0ffffff98h
UNZ_CRCERROR		EQU		0ffffff97h
;----------------------------------------------------------------
Z_NO_FLUSH		EQU		0t
Z_PARTIAL_FLUSH		EQU		1t
Z_SYNC_FLUSH		EQU		2t
Z_FULL_FLUSH		EQU		3t
Z_FINISH		EQU		4t
Z_OK		EQU		0t
Z_STREAM_END		EQU		1t
Z_NEED_DICT		EQU		2t
Z_ERRNO		EQU		0ffffffffh
Z_STREAM_ERROR		EQU		0fffffffeh
Z_DATA_ERROR		EQU		0fffffffdh
Z_MEM_ERROR		EQU		0fffffffch
Z_BUF_ERROR		EQU		0fffffffbh
Z_VERSION_ERROR		EQU		0fffffffah
Z_NO_COMPRESSION		EQU		0t
Z_BEST_SPEED		EQU		1t
Z_BEST_COMPRESSION		EQU		9t
Z_DEFAULT_COMPRESSION		EQU		0ffffffffh
Z_FILTERED		EQU		1t
Z_HUFFMAN_ONLY		EQU		2t
Z_DEFAULT_STRATEGY		EQU		0t
Z_BINARY		EQU		0t
Z_ASCII		EQU		1t
Z_UNKNOWN		EQU		2t
Z_DEFLATED		EQU		8t
Z_NULL		EQU		0t
;-------------------------------------------------------------------
ZLIB_FILEFUNC_SEEK_CUR		EQU		000000001h
ZLIB_FILEFUNC_SEEK_END		EQU		000000002h
ZLIB_FILEFUNC_SEEK_SET		EQU		000000000h
ZLIB_FILEFUNC_MODE_READ		EQU		000000001h
ZLIB_FILEFUNC_MODE_WRITE		EQU		000000002h
ZLIB_FILEFUNC_MODE_READWRITEFILTER		EQU		000000003h
ZLIB_FILEFUNC_MODE_EXISTING		EQU		000000004h
ZLIB_FILEFUNC_MODE_CREATE		EQU		000000008h
