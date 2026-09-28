# include 
DATA:  lt_fname1    TYPE fbname.

  "Constant Declaration
  CONSTANTS: lc_include1 TYPE sobj_name VALUE 'ZCOMV_DOC_PREP_MV45AFZZ_01',
             lc_key_1    TYPE zexitkey  VALUE 'VKORG/VTWEG/SPART/AUART',
             lc_sls_inco TYPE char1     VALUE '/'.

  DATA(lv_val_1) = |{ vbak-vkorg }{ lc_sls_inco }{ vbak-vtweg }{ lc_sls_inco }{ vbak-spart }{ lc_sls_inco }{ vbak-auart }|.

*--- User Exit Check ---
  "Call Exit FM
  CALL FUNCTION 'ZEXIT_CHECK'
    EXPORTING
      p_include   = lc_include1
      p_key1      = lc_key_1
      p_val1      = lv_val_1
    CHANGING
      func_module = lt_fname1
    EXCEPTIONS
      not_active  = 1
      OTHERS      = 2.
  IF sy-subrc EQ 0. " Exit is active
    LOOP AT lt_fname1 ASSIGNING FIELD-SYMBOL(<fs_fm_1>).
      CALL FUNCTION <fs_fm_1>
        EXPORTING
          in_vbak   = vbak
          in_vbap   = vbap
          in_vbkd   = vbkd
          in_vbep   = vbep
          in_vbuk   = vbuk
          in_vbup   = vbup
          in_yvbak  = yvbak
          in_xvbap  = xvbap
          in_t180   = t180
        IMPORTING
          out_vbak  = vbak
          out_vbap  = vbap
          out_vbkd  = vbkd
          out_vbep  = vbep
          out_vbuk  = vbuk
          out_vbup  = vbup
          out_yvbak = yvbak
          out_xvbap = xvbap
        TABLES
          t_xvbap   = xvbap[]
          t_xvbfa   = xvbfa[]
          t_xvbkd   = xvbkd[]
          t_xvbep   = xvbep[]
          t_xvbuk   = xvbuk[]
          t_xvbup   = xvbup[]
          t_xvbpa   = xvbpa[]
          t_yvbap   = yvbap[]
          t_yvbfa   = yvbfa[]
          t_yvbkd   = yvbkd[]
          t_yvbep   = yvbep[]
          t_yvbuk   = yvbuk[]
          t_yvbup   = yvbup[]
          t_cvbap   = cvbap[]
          t_cvbfa   = cvbfa[]
          t_cvbkd   = cvbkd[]
          t_cvbep   = cvbep[]
          t_cvbup   = cvbup[]
          t_vvbap   = vvbap[]
        CHANGING
          cs_vbak   = vbak
          cs_vbkd   = vbkd.
    ENDLOOP.
ENDIF.

#Function modules-1

FUNCTION zcomv_inco_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IN_VBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_VBAP) TYPE  VBAP OPTIONAL
*"     REFERENCE(IN_VBKD) TYPE  VBKD OPTIONAL
*"     REFERENCE(IN_VBEP) TYPE  VBEP OPTIONAL
*"     REFERENCE(IN_VBUK) TYPE  VBUK OPTIONAL
*"     REFERENCE(IN_VBUP) TYPE  VBUP OPTIONAL
*"     REFERENCE(IN_YVBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_XVBAP) TYPE  VBAPVB OPTIONAL
*"     REFERENCE(IN_T180) TYPE  T180 OPTIONAL
*"  EXPORTING
*"     REFERENCE(OUT_VBAK) TYPE  VBAK
*"     REFERENCE(OUT_VBAP) TYPE  VBAP
*"     REFERENCE(OUT_VBKD) TYPE  VBKD
*"     REFERENCE(OUT_VBEP) TYPE  VBEP
*"     REFERENCE(OUT_VBUK) TYPE  VBUK
*"     REFERENCE(OUT_VBUP) TYPE  VBUP
*"     REFERENCE(OUT_YVBAK) TYPE  VBAK
*"     REFERENCE(OUT_XVBAP) TYPE  VBAPVB
*"  TABLES
*"      T_XVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_XVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_XVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_XVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_XVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_XVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_XVBPA STRUCTURE  VBPAVB OPTIONAL
*"      T_YVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_YVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_YVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_YVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_YVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_YVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_CVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_CVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_CVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_CVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_CVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_VVBAP STRUCTURE  VBAPVB OPTIONAL
*"  CHANGING
*"     REFERENCE(CS_VBAK) TYPE  VBAK
*"     REFERENCE(CS_VBKD) TYPE  VBKD
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Development ID:  ZDDE-00084653                                      *
*& Functional Spec: ZFSE-00084652                                      *
*&---------------------------------------------------------------------*
*& Title : Determine Sales Fields from Customer Master                 *
*& This FM triggers from Include ZCOMV_INCO_TERMS_MTO from             *                                                                 *
*& USEREXIT_SAVE_DOC_PREPARE in standard program MV45AFZZ.This will    *
*& update inco terms on header and line items based on ship-to-party.  *
*& Include: ZCOMV_INCO_TERMS_MTO                                       *
*&---------------------------------------------------------------------*
*& Change Log:                                                         *
*&---------------------------------------------------------------------*
*& Init     |  Name     |     Date   |            Text                 *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  29-Jul-2024  CR:   1100242932 Initial version *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  13-Jan-2025 CR: 1100262097	Changes done for   *
*&                                                  Inco terms under   *
*&                                                  INC 2100416900     *
*&---------------------------------------------------------------------*

  CONSTANTS: lc_we       TYPE parvw     VALUE 'WE',
             lc_trtyp_ch TYPE char1     VALUE 'V',
             lc_trtyp_cr TYPE char1     VALUE 'H',
             lc_u        TYPE updkz_d   VALUE 'U',
             lc_i        TYPE updkz_d   VALUE 'I'.

  IF t_xvbpa[] IS NOT INITIAL.
    SELECT kunnr,
          inco1,
          inco2
     FROM knvv
      FOR ALL ENTRIES IN @t_xvbpa
    WHERE kunnr = @t_xvbpa-kunnr
      AND vkorg = @cs_vbak-vkorg
      AND vtweg = @cs_vbak-vtweg
      AND spart = @cs_vbak-spart
     INTO TABLE @DATA(lt_knvv).
    IF sy-subrc EQ 0.
      ASSIGN t_xvbpa[ vbeln = cs_vbak-vbeln parvw = lc_we ] TO FIELD-SYMBOL(<lfs_vbpa1>). "Read Ship-to-party
    ENDIF.
  ENDIF.

  IF in_t180-trtyp EQ lc_trtyp_ch.
    IF <lfs_vbpa1> IS ASSIGNED.
      IF <lfs_vbpa1>-updkz NE lc_u AND <lfs_vbpa1>-updkz NE lc_i.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT vbeln, posnr, inco1, inco2
      FROM vbkd
      INTO TABLE @DATA(lt_vbkd)
      WHERE vbeln = @cs_vbak-vbeln
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      LOOP AT t_xvbkd ASSIGNING FIELD-SYMBOL(<lfs_vbkd>).
        IF <lfs_vbkd> IS ASSIGNED.
          IF NOT line_exists( lt_vbkd[ posnr = <lfs_vbkd>-posnr inco1 = <lfs_vbkd>-inco1 inco2 = <lfs_vbkd>-inco2 ] ).
            DATA(lv_manual_check) = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lv_manual_check IS NOT INITIAL. "Checking if manual changes are done
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  "Updating Inco terms based on Ship-to-party
  ASSIGN lt_knvv[ kunnr = <lfs_vbpa1>-kunnr ] TO FIELD-SYMBOL(<lfs_knvv>).
  IF <lfs_knvv> IS ASSIGNED.
    LOOP AT t_xvbkd ASSIGNING <lfs_vbkd>.
      IF <lfs_vbkd> IS ASSIGNED.
        <lfs_vbkd>-inco1 = <lfs_knvv>-inco1.
        <lfs_vbkd>-inco2 = <lfs_knvv>-inco2.
        IF <lfs_vbkd>-updkz EQ space.
          <lfs_vbkd>-updkz = lc_u.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.

#Function modules-2

FUNCTION zcomv_sales_ofc_grp_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IN_VBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_VBAP) TYPE  VBAP OPTIONAL
*"     REFERENCE(IN_VBKD) TYPE  VBKD OPTIONAL
*"     REFERENCE(IN_VBEP) TYPE  VBEP OPTIONAL
*"     REFERENCE(IN_VBUK) TYPE  VBUK OPTIONAL
*"     REFERENCE(IN_VBUP) TYPE  VBUP OPTIONAL
*"     REFERENCE(IN_YVBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_XVBAP) TYPE  VBAPVB OPTIONAL
*"     REFERENCE(IN_T180) TYPE  T180 OPTIONAL
*"  EXPORTING
*"     REFERENCE(OUT_VBAK) TYPE  VBAK
*"     REFERENCE(OUT_VBAP) TYPE  VBAP
*"     REFERENCE(OUT_VBKD) TYPE  VBKD
*"     REFERENCE(OUT_VBEP) TYPE  VBEP
*"     REFERENCE(OUT_VBUK) TYPE  VBUK
*"     REFERENCE(OUT_VBUP) TYPE  VBUP
*"     REFERENCE(OUT_YVBAK) TYPE  VBAK
*"     REFERENCE(OUT_XVBAP) TYPE  VBAPVB
*"  TABLES
*"      T_XVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_XVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_XVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_XVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_XVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_XVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_XVBPA STRUCTURE  VBPAVB OPTIONAL
*"      T_YVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_YVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_YVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_YVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_YVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_YVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_CVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_CVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_CVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_CVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_CVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_VVBAP STRUCTURE  VBAPVB OPTIONAL
*"  CHANGING
*"     REFERENCE(CS_VBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(CS_VBKD) TYPE  VBKD OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Development ID:  ZDDE-00084653                                      *
*& Functional Spec: ZFSE-00084652                                      *
*&---------------------------------------------------------------------*
*& Title : Determine Sales Fields from Customer Master                 *
*& This FM triggers from Include ZCOMV_INCO_TERMS_MTO from             *                                                                 *
*& USEREXIT_SAVE_DOC_PREPARE in standard program MV45AFZZ.This will    *
*& update salesoffice and sales group on header and line items based on*
*& ship-to-party.                                                      *
*& Include: ZCOMV_INCO_TERMS_MTO                                       *
*&---------------------------------------------------------------------*
*& Change Log:                                                         *
*&---------------------------------------------------------------------*
*& Init     |  Name     |     Date   |            Text                 *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  29-Jul-2024 CR:   Initial 	1100262097 version *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  13-Jan-2025 CR: 1100262097	Changes done for   *
*&                                                  Salesoffice and    *
*&                                                  Salesgroup under   *
*&                                                  INC 2100416900     *
*&---------------------------------------------------------------------*

  CONSTANTS: lc_prog_name TYPE program_id VALUE 'ZCOMV_INCO_MTO_SAVE',
             lc_we        TYPE parvw      VALUE 'WE',
             lc_u         TYPE updkz_d    VALUE 'U',
             lc_i         TYPE updkz_d    VALUE 'I',
             lc_trtyp_ch  TYPE char1      VALUE 'V'.

  DATA: lv_param_id TYPE rvari_vnam.

  IF t_xvbpa[] IS NOT INITIAL.
    SELECT kunnr, vkgrp, vkbur
     FROM knvv
     FOR ALL ENTRIES IN @t_xvbpa
     WHERE kunnr = @t_xvbpa-kunnr
     AND vkorg = @cs_vbak-vkorg
     AND vtweg = @cs_vbak-vtweg
     AND spart = @cs_vbak-spart
     INTO TABLE @DATA(lt_knvv).
    IF sy-subrc EQ 0 AND lt_knvv IS NOT INITIAL.
      ASSIGN t_xvbpa[ parvw = lc_we ] TO FIELD-SYMBOL(<lfs_vbpa1>).
      ASSIGN lt_knvv[ kunnr = <lfs_vbpa1>-kunnr ] TO FIELD-SYMBOL(<lfs_knvv>).
      IF <lfs_knvv> IS ASSIGNED.
        DATA(lv_vkbur) = <lfs_knvv>-vkbur.
        DATA(lv_vkgrp) = <lfs_knvv>-vkgrp.
      ENDIF.
    ENDIF.
  ENDIF.

  IF in_t180-trtyp EQ lc_trtyp_ch AND ( in_yvbak-vkbur NE cs_vbak-vkbur OR in_yvbak-vkgrp NE cs_vbak-vkgrp ).
    RETURN.
  ENDIF.

  ASSIGN t_xvbpa[ vbeln = cs_vbak-vbeln parvw = lc_we ] TO <lfs_vbpa1>. "Read Ship-to-party
  IF <lfs_vbpa1> IS ASSIGNED.
    IF <lfs_vbpa1>-updkz NE lc_u AND <lfs_vbpa1>-updkz NE lc_i.
      RETURN.
    ENDIF.
  ENDIF.

  IF lv_vkbur IS INITIAL.
    ASSIGN t_xvbap[ vbeln = cs_vbak-vbeln ] TO FIELD-SYMBOL(<lfs_vbap>).
    IF <lfs_vbap> IS ASSIGNED AND <lfs_vbap>-matnr IS NOT INITIAL.
      SELECT SINGLE zzbunit
        FROM mara
        INTO @DATA(lv_zzbunit)
       WHERE matnr EQ @<lfs_vbap>-matnr. "Getting business unit based on material
      IF sy-subrc EQ 0 AND lv_zzbunit IS NOT INITIAL.
        lv_param_id = lv_zzbunit.
        SELECT value UP TO 1 ROWS
          FROM zcomv_param_gtec
          INTO @DATA(lv_vkbur_val)
          WHERE prog_name = @lc_prog_name
          AND parameter_id = @lv_param_id
          ORDER BY counter.
        ENDSELECT.
        IF sy-subrc EQ 0 AND lv_vkbur_val IS NOT INITIAL.
          lv_vkbur = lv_vkbur_val.
        ENDIF.
        IF lv_vkbur IS NOT INITIAL.
          SELECT vkgrp UP TO 1 ROWS
            FROM tvbvk
            INTO @DATA(lv_vkgrp_val)
            WHERE vkbur = @lv_vkbur
            ORDER BY PRIMARY KEY.
          ENDSELECT.
          IF sy-subrc EQ 0 AND lv_vkgrp_val IS NOT INITIAL.
            lv_vkgrp = lv_vkgrp_val.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lv_vkbur IS NOT INITIAL.
    cs_vbak-vkbur = lv_vkbur.
    cs_vbak-vkgrp = lv_vkgrp.
  ENDIF.

ENDFUNCTION.

#FUNCTION MODULES-3

FUNCTION zcomv_zterm_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IN_VBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_VBAP) TYPE  VBAP OPTIONAL
*"     REFERENCE(IN_VBKD) TYPE  VBKD OPTIONAL
*"     REFERENCE(IN_VBEP) TYPE  VBEP OPTIONAL
*"     REFERENCE(IN_VBUK) TYPE  VBUK OPTIONAL
*"     REFERENCE(IN_VBUP) TYPE  VBUP OPTIONAL
*"     REFERENCE(IN_YVBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IN_XVBAP) TYPE  VBAPVB OPTIONAL
*"     REFERENCE(IN_T180) TYPE  T180 OPTIONAL
*"  EXPORTING
*"     REFERENCE(OUT_VBAK) TYPE  VBAK
*"     REFERENCE(OUT_VBAP) TYPE  VBAP
*"     REFERENCE(OUT_VBKD) TYPE  VBKD
*"     REFERENCE(OUT_VBEP) TYPE  VBEP
*"     REFERENCE(OUT_VBUK) TYPE  VBUK
*"     REFERENCE(OUT_VBUP) TYPE  VBUP
*"     REFERENCE(OUT_YVBAK) TYPE  VBAK
*"     REFERENCE(OUT_XVBAP) TYPE  VBAPVB
*"  TABLES
*"      T_XVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_XVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_XVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_XVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_XVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_XVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_XVBPA STRUCTURE  VBPAVB OPTIONAL
*"      T_YVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_YVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_YVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_YVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_YVBUK STRUCTURE  VBUKVB OPTIONAL
*"      T_YVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_CVBAP STRUCTURE  VBAPVB OPTIONAL
*"      T_CVBFA STRUCTURE  VBFAVB OPTIONAL
*"      T_CVBKD STRUCTURE  VBKDVB OPTIONAL
*"      T_CVBEP STRUCTURE  VBEPVB OPTIONAL
*"      T_CVBUP STRUCTURE  VBUPVB OPTIONAL
*"      T_VVBAP STRUCTURE  VBAPVB OPTIONAL
*"  CHANGING
*"     REFERENCE(CS_VBAK) TYPE  VBAK
*"     REFERENCE(CS_VBKD) TYPE  VBKD
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Development ID:  ZDDE-00084653                                      *
*& Functional Spec: ZFSE-00084652                                      *
*&---------------------------------------------------------------------*
*& Title : Determine Sales Fields from Customer Master                 *
*& This FM triggers from Include ZCOMV_INCO_TERMS_MTO from             *                                                                 *
*& USEREXIT_SAVE_DOC_PREPARE in standard program MV45AFZZ.This will    *
*& update payment terms on header and line items based on              *
*& ship-to-party.                                                      *
*& Include: ZCOMV_INCO_TERMS_MTO                                       *
*&---------------------------------------------------------------------*
*& Change Log:                                                         *
*&---------------------------------------------------------------------*
*& Init     |  Name     |     Date   |            Text                 *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  29-Jul-2024 CR:   Initial 	1100262097 version *
*&---------------------------------------------------------------------*
*& AMIREHA1 A.HARSHITHA  13-Jan-2025 CR: 1100262097	Changes done for   *
*&                                                 Payment terms under *
*&                                                 INC 2100416900      *
*&---------------------------------------------------------------------*
  CONSTANTS: lc_we       TYPE parvw     VALUE 'WE',
             lc_trtyp_ch TYPE char1     VALUE 'V',
             lc_trtyp_cr TYPE char1     VALUE 'H',
             lc_u        TYPE updkz_d   VALUE 'U',
             lc_i        TYPE updkz_d   VALUE 'I'.

  IF t_xvbpa[] IS NOT INITIAL.
    SELECT kunnr,
          zterm
     FROM knvv
      FOR ALL ENTRIES IN @t_xvbpa
    WHERE kunnr = @t_xvbpa-kunnr
      AND vkorg = @cs_vbak-vkorg
      AND vtweg = @cs_vbak-vtweg
      AND spart = @cs_vbak-spart
     INTO TABLE @DATA(lt_knvv).
    IF sy-subrc EQ 0.
      ASSIGN t_xvbpa[ vbeln = cs_vbak-vbeln parvw = lc_we ] TO FIELD-SYMBOL(<lfs_vbpa1>). "Read Ship-to-party
    ENDIF.
  ENDIF.

  IF in_t180-trtyp EQ lc_trtyp_ch.
    IF <lfs_vbpa1> IS ASSIGNED.
      IF <lfs_vbpa1>-updkz NE lc_u AND <lfs_vbpa1>-updkz NE lc_i.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT vbeln, posnr, zterm
      FROM vbkd
      INTO TABLE @DATA(lt_vbkd)
      WHERE vbeln = @cs_vbak-vbeln
      ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      LOOP AT t_xvbkd ASSIGNING FIELD-SYMBOL(<lfs_vbkd>).
        IF <lfs_vbkd> IS ASSIGNED.
          IF NOT line_exists( lt_vbkd[ posnr = <lfs_vbkd>-posnr zterm = <lfs_vbkd>-zterm ] ).
            DATA(lv_manual_check) = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lv_manual_check IS NOT INITIAL."Checking if manual changes are done
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  "Updating payment terms based on Ship-to-party
  ASSIGN lt_knvv[ kunnr = <lfs_vbpa1>-kunnr ] TO FIELD-SYMBOL(<lfs_knvv>).
  IF <lfs_knvv> IS ASSIGNED.
    LOOP AT t_xvbkd ASSIGNING <lfs_vbkd>.
      IF <lfs_vbkd> IS ASSIGNED.
        <lfs_vbkd>-zterm = <lfs_knvv>-zterm.
        IF <lfs_vbkd>-updkz EQ space.
          <lfs_vbkd>-updkz = lc_u.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.

