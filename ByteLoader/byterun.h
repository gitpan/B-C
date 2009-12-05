/* -*- buffer-read-only: t -*-
 *
 *      Copyright (c) 1996-1999 Malcolm Beattie
 *      Copyright (c) 2008,2009 Reini Urban
 *
 *      You may distribute under the terms of either the GNU General Public
 *      License or the Artistic License, as specified in the README file.
 *
 */
/*
 * This file is autogenerated from bytecode.pl. Changes made here will be lost.
 */
#if PERL_VERSION < 10
  #define PL_RSFP PL_rsfp
#else
  #define PL_RSFP PL_parser->rsfp
#endif

#if (PERL_VERSION <= 8) && (PERL_SUBVERSION < 8)
  #define NEED_sv_2pv_flags
  #include "ppport.h"
#endif

/* macros for correct constant construction */
# if INTSIZE >= 2
#  define U16_CONST(x) ((U16)x##U)
# else
#  define U16_CONST(x) ((U16)x##UL)
# endif

# if INTSIZE >= 4
#  define U32_CONST(x) ((U32)x##U)
# else
#  define U32_CONST(x) ((U32)x##UL)
# endif

# ifdef HAS_QUAD
typedef I64TYPE I64;
typedef U64TYPE U64;
#  if INTSIZE >= 8
#   define U64_CONST(x) ((U64)x##U)
#  elif LONGSIZE >= 8
#   define U64_CONST(x) ((U64)x##UL)
#  elif QUADKIND == QUAD_IS_LONG_LONG
#   define U64_CONST(x) ((U64)x##ULL)
#  else /* best guess we can make */
#   define U64_CONST(x) ((U64)x##UL)
#  endif
# endif

/* byte-swapping functions for big-/little-endian conversion */
# define _swab_16_(x) ((U16)( \
         (((U16)(x) & U16_CONST(0x00ff)) << 8) | \
         (((U16)(x) & U16_CONST(0xff00)) >> 8) ))

# define _swab_32_(x) ((U32)( \
         (((U32)(x) & U32_CONST(0x000000ff)) << 24) | \
         (((U32)(x) & U32_CONST(0x0000ff00)) <<  8) | \
         (((U32)(x) & U32_CONST(0x00ff0000)) >>  8) | \
         (((U32)(x) & U32_CONST(0xff000000)) >> 24) ))

# ifdef HAS_QUAD
#  define _swab_64_(x) ((U64)( \
          (((U64)(x) & U64_CONST(0x00000000000000ff)) << 56) | \
          (((U64)(x) & U64_CONST(0x000000000000ff00)) << 40) | \
          (((U64)(x) & U64_CONST(0x0000000000ff0000)) << 24) | \
          (((U64)(x) & U64_CONST(0x00000000ff000000)) <<  8) | \
          (((U64)(x) & U64_CONST(0x000000ff00000000)) >>  8) | \
          (((U64)(x) & U64_CONST(0x0000ff0000000000)) >> 24) | \
          (((U64)(x) & U64_CONST(0x00ff000000000000)) >> 40) | \
          (((U64)(x) & U64_CONST(0xff00000000000000)) >> 56) ))
# else
#  define _swab_64_(x) _swab_32_((U32)(x) & U32_CONST(0xffffffff))
# endif

#  define _swab_iv_(x,size) ((size==4) ? _swab_32_(x) : ((size==8) ? _swab_64_(x) : _swab_16_(x)))

struct byteloader_fdata {
    SV	*datasv;
    int  next_out;
    int	 idx;
};

#if PERL_VERSION > 8

struct byteloader_xpv {
    char *xpv_pv;
    int   xpv_cur;
    int	  xpv_len;
};

#endif

struct byteloader_header {
    char 	archname[80];
    char 	version[16];
    int 	ivsize;
    int 	ptrsize;
    int 	longsize;
    char 	byteorder[16];
    int 	archflag;
} bl_header;

struct byteloader_state {
    struct byteloader_fdata	*bs_fdata;
    SV				*bs_sv;
    void			**bs_obj_list;
    int				bs_obj_list_fill;
    int				bs_ix;
#if PERL_VERSION > 8
    struct byteloader_xpv	bs_pv;
#else
    XPV				bs_pv;
#endif
    int				bs_iv_overflows;
};

int bl_getc(struct byteloader_fdata *);
int bl_read(struct byteloader_fdata *, char *, size_t, size_t);
extern int byterun(pTHX_ register struct byteloader_state *);

enum {
    INSN_RET,			/* 0 */
    INSN_LDSV,			/* 1 */
    INSN_LDOP,			/* 2 */
    INSN_STSV,			/* 3 */
    INSN_STOP,			/* 4 */
    INSN_STPV,			/* 5 */
    INSN_LDSPECSV,			/* 6 */
    INSN_LDSPECSVX,			/* 7 */
    INSN_NEWSV,			/* 8 */
    INSN_NEWSVX,			/* 9 */
    INSN_NOP,			/* 10 */
    INSN_NEWOP,			/* 11 */
    INSN_NEWOPX,			/* 12 */
    INSN_NEWOPN,			/* 13 */
    INSN_NEWPV,			/* 14 */
    INSN_PV_CUR,			/* 15 */
    INSN_PV_FREE,			/* 16 */
    INSN_SV_UPGRADE,			/* 17 */
    INSN_SV_REFCNT,			/* 18 */
    INSN_SV_REFCNT_ADD,			/* 19 */
    INSN_SV_FLAGS,			/* 20 */
    INSN_XRV,			/* 21 */
    INSN_XPV,			/* 22 */
    INSN_XPV_CUR,			/* 23 */
    INSN_XPV_LEN,			/* 24 */
    INSN_XIV32,			/* 25 */
    INSN_XIV64,			/* 26 */
    INSN_XNV,			/* 27 */
    INSN_XLV_TARGOFF,			/* 28 */
    INSN_XLV_TARGLEN,			/* 29 */
    INSN_XLV_TARG,			/* 30 */
    INSN_XLV_TYPE,			/* 31 */
    INSN_XBM_USEFUL,			/* 32 */
    INSN_XBM_PREVIOUS,			/* 33 */
    INSN_XBM_RARE,			/* 34 */
    INSN_COMMENT,			/* 35 */
    INSN_XFM_LINES,			/* 36 */
    INSN_XIO_LINES,			/* 37 */
    INSN_XIO_PAGE,			/* 38 */
    INSN_XIO_PAGE_LEN,			/* 39 */
    INSN_XIO_LINES_LEFT,			/* 40 */
    INSN_XIO_TOP_NAME,			/* 41 */
    INSN_XIO_TOP_GV,			/* 42 */
    INSN_XIO_FMT_NAME,			/* 43 */
    INSN_XIO_FMT_GV,			/* 44 */
    INSN_XIO_BOTTOM_NAME,			/* 45 */
    INSN_XIO_BOTTOM_GV,			/* 46 */
    INSN_XIO_SUBPROCESS,			/* 47 */
    INSN_XIO_TYPE,			/* 48 */
    INSN_XIO_FLAGS,			/* 49 */
    INSN_XCV_XSUBANY,			/* 50 */
    INSN_XCV_STASH,			/* 51 */
    INSN_XCV_START,			/* 52 */
    INSN_XCV_ROOT,			/* 53 */
    INSN_XCV_GV,			/* 54 */
    INSN_XCV_FILE,			/* 55 */
    INSN_XCV_DEPTH,			/* 56 */
    INSN_XCV_PADLIST,			/* 57 */
    INSN_XCV_OUTSIDE,			/* 58 */
    INSN_XCV_FLAGS,			/* 59 */
    INSN_AV_EXTEND,			/* 60 */
    INSN_AV_PUSHX,			/* 61 */
    INSN_AV_PUSH,			/* 62 */
    INSN_XAV_FILL,			/* 63 */
    INSN_XAV_MAX,			/* 64 */
    INSN_XAV_FLAGS,			/* 65 */
    INSN_XHV_RITER,			/* 66 */
    INSN_XHV_NAME,			/* 67 */
    INSN_HV_STORE,			/* 68 */
    INSN_SV_MAGIC,			/* 69 */
    INSN_MG_OBJ,			/* 70 */
    INSN_MG_PRIVATE,			/* 71 */
    INSN_MG_FLAGS,			/* 72 */
    INSN_MG_NAME,			/* 73 */
    INSN_MG_NAMEX,			/* 74 */
    INSN_XMG_STASH,			/* 75 */
    INSN_GV_FETCHPV,			/* 76 */
    INSN_GV_FETCHPVX,			/* 77 */
    INSN_GV_STASHPV,			/* 78 */
    INSN_GV_STASHPVX,			/* 79 */
    INSN_GP_SV,			/* 80 */
    INSN_GP_REFCNT,			/* 81 */
    INSN_GP_REFCNT_ADD,			/* 82 */
    INSN_GP_AV,			/* 83 */
    INSN_GP_HV,			/* 84 */
    INSN_GP_CV,			/* 85 */
    INSN_GP_FILE,			/* 86 */
    INSN_GP_IO,			/* 87 */
    INSN_GP_FORM,			/* 88 */
    INSN_GP_CVGEN,			/* 89 */
    INSN_GP_LINE,			/* 90 */
    INSN_GP_SHARE,			/* 91 */
    INSN_XGV_FLAGS,			/* 92 */
    INSN_OP_NEXT,			/* 93 */
    INSN_OP_SIBLING,			/* 94 */
    INSN_OP_PPADDR,			/* 95 */
    INSN_OP_TARG,			/* 96 */
    INSN_OP_TYPE,			/* 97 */
    INSN_OP_SEQ,			/* 98 */
    INSN_OP_FLAGS,			/* 99 */
    INSN_OP_PRIVATE,			/* 100 */
    INSN_OP_FIRST,			/* 101 */
    INSN_OP_LAST,			/* 102 */
    INSN_OP_OTHER,			/* 103 */
    INSN_OP_PMREPLROOT,			/* 104 */
    INSN_OP_PMREPLSTART,			/* 105 */
    INSN_OP_PMNEXT,			/* 106 */
    INSN_OP_PMREPLROOTPO,			/* 107 */
    INSN_OP_PMREPLROOTGV,			/* 108 */
    INSN_PREGCOMP,			/* 109 */
    INSN_OP_PMFLAGS,			/* 110 */
    INSN_OP_PMPERMFLAGS,			/* 111 */
    INSN_OP_PMDYNFLAGS,			/* 112 */
    INSN_OP_SV,			/* 113 */
    INSN_OP_PADIX,			/* 114 */
    INSN_OP_PV,			/* 115 */
    INSN_OP_PV_TR,			/* 116 */
    INSN_OP_REDOOP,			/* 117 */
    INSN_OP_NEXTOP,			/* 118 */
    INSN_OP_LASTOP,			/* 119 */
    INSN_COP_LABEL,			/* 120 */
    INSN_COP_STASHPV,			/* 121 */
    INSN_COP_FILE,			/* 122 */
    INSN_COP_STASH,			/* 123 */
    INSN_COP_FILEGV,			/* 124 */
    INSN_COP_SEQ,			/* 125 */
    INSN_COP_ARYBASE,			/* 126 */
    INSN_COP_LINE,			/* 127 */
    INSN_COP_WARNINGS,			/* 128 */
    INSN_MAIN_START,			/* 129 */
    INSN_MAIN_ROOT,			/* 130 */
    INSN_MAIN_CV,			/* 131 */
    INSN_CURPAD,			/* 132 */
    INSN_PUSH_BEGIN,			/* 133 */
    INSN_PUSH_INIT,			/* 134 */
    INSN_PUSH_END,			/* 135 */
    MAX_INSN = 135
};

enum {
    OPt_OP,		/* 0 */
    OPt_UNOP,		/* 1 */
    OPt_BINOP,		/* 2 */
    OPt_LOGOP,		/* 3 */
    OPt_LISTOP,		/* 4 */
    OPt_PMOP,		/* 5 */
    OPt_SVOP,		/* 6 */
    OPt_PADOP,		/* 7 */
    OPt_PVOP,		/* 8 */
    OPt_LOOP,		/* 9 */
    OPt_COP		/* 10 */
};

/* ex: set ro: */
