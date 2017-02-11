

;typedef struct _OMF_HEADER
;{
;WORD wRecordSize; // in bytes, not including this member
;WORD wRecordType;
;}
;OMF_HEADER, *POMF_HEADER, **PPOMF_HEADER;
;#define OMF_HEADER_ sizeof (OMF_HEADER)
;// -----------------------------------------------------------------
;typedef struct _OMF_NAME
;{
;BYTE bLength; // in bytes, not including this member
;BYTE abName [];
;}
;OMF_NAME, *POMF_NAME, **PPOMF_NAME;
;#define OMF_NAME_ sizeof (OMF_NAME)
;
;#define S_PUB32 0x0203
;#define S_ALIGN 0x0402
;#define CV_PUB32 S_PUB32
;// -----------------------------------------------------------------
;#define PDB_PUB32 0x1009
;// -----------------------------------------------------------------
;typedef struct _PDB_PUBSYM
;{
;OMF_HEADER Header;
;DWORD dReserved;
;DWORD dOffset;
;WORD wSegment; // 1-based section index
;OMF_NAME Name; // zero-padded to next DWORD
;}
;PDB_PUBSYM, *PPDB_PUBSYM, **PPPDB_PUBSYM;
;#define PDB_PUBSYM_ sizeof (PDB_PUBSYM)
;#define PDB_PUBSYM_SIZE(_p) \
;((DWORD) (_p)->Header.wRecordSize + sizeof (WORD))
;#define PDB_PUBSYM_NEXT(_p) \
;((PPDB_PUBSYM) ((PBYTE) (_p) + PDB_PUBSYM_SIZE (_p)))

.code
