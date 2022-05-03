class ZCL_MMPUR_OCI_PR_TO_PO definition
  public
  final
  create public .

public section.

  data GV_BANFN type BANFN read-only .
  data GV_CREATOR type ERNAM .
  data GT_EBELN type FIP_T_EBELN_LIST read-only .

  methods CONSTRUCTOR
    importing
      !IV_BANFN type BANFN .
protected section.
private section.

  types:
    BEGIN OF ts_item_flief ,
      vendor TYPE flief,
      items  TYPE ty_bapimereqitem,
    END OF ts_item_flief .
  types:
    tt_item_flief TYPE STANDARD TABLE OF ts_item_flief .
  types:
    BEGIN OF type_s_packno,
     packno TYPE packno,
     dummy  TYPE packno,
   END OF type_s_packno .
  types:
    type_t_packno TYPE SORTED TABLE OF type_s_packno
                 WITH UNIQUE KEY packno .

  data GT_ITEMS_PER_VENDOR type TT_ITEM_FLIEF .
  data MO_CONST type ref to CL_MMPUR_CONSTANTS .
  data MT_PACKAGE type TYPE_T_PACKNO .
  data MV_PACKNO type PACKNO .

  methods CREATE_PO
    importing
      !IT_PR_ITEMS_SET type MMPURUI_PR_ITEMS_TTY
      value(IV_SOS) type FLIEF
      value(IV_COMMIT_DATA) type BOOLEAN
    exporting
      !ET_RETURN_MESSAGES type BAPIRETTAB
      !EV_PO_CREATED_STATUS type BOOLEAN .
  methods GET_PR_DETAIL .
  methods GET_PR_SERVICE_DATA
    importing
      !IV_PACKNO type PACKNO
    exporting
      !ET_SERVICE_DATA type BAPIESLLC_TP .
  methods REPLACE_PACKNO
    importing
      !IV_SUBPACK type MMPUR_BOOL default ABAP_FALSE
      !IV_PACKNO type PACKNO
    exporting
      !EV_PACKNO type PACKNO
    changing
      !CT_SERVICE type BAPIESLLC_TP
      !CT_ACCOUNT type BAPIESKLC_TP .
  methods GET_DUMMY_PACKNO
    returning
      value(RV_PACKNO) type PACKNO .
  methods MAP_PR_2_BAPI .
  methods GET_PO_NUMBER
    importing
      !IT_PR_ITEMS type MMPURUI_PR_ITEMS_TTY .
ENDCLASS.



CLASS ZCL_MMPUR_OCI_PR_TO_PO IMPLEMENTATION.


  METHOD constructor.

    me->gv_banfn = iv_banfn.

* PR Details
me->GET_PR_DETAIL( ).

* MAP and Create PO
me->MAP_PR_2_BAPI( ).

  ENDMETHOD.


  METHOD create_po.
* define local data objects
    DATA: lo_util      TYPE REF TO cl_mmpur_utilities,
          lo_cppr      TYPE REF TO cl_mmpur_ui_cppr,
          lo_badi      TYPE REF TO me_bsart_determine,
          lo_db        TYPE REF TO cl_mmpur_mepo_db_utility,
          lt_item      TYPE bapimepoitem_tp,
          lt_itemx     TYPE bapimepoitemx_tp,
          lt_account   TYPE bapimepoaccount_tp,
          lt_accountx  TYPE bapimepoaccountx_tp,
          lt_acc_tmp   TYPE bapimepoaccount_tp,
          lt_services  TYPE bapiesllc_tp,
          lt_services1 TYPE bapiesllc_tp,
          lt_srv_acc   TYPE bapiesklc_tp,
          lt_srv_acc1  TYPE bapiesklc_tp,
          ls_header    TYPE  bapimepoheader,
          ls_headerx   TYPE bapimepoheaderx,
          ls_item      TYPE bapimepoitem,
          ls_itemx     TYPE bapimepoitemx,
          ls_eban      TYPE eban,
          ls_t161      TYPE t161,
          ls_accountx  TYPE bapimepoaccountx,
          lv_item_no   TYPE ebelp,
          lv_po_number TYPE ebeln,
          lv_gpstyp    TYPE c LENGTH 1,
          lv_bsart     TYPE bsart,
          lv_testrun   TYPE c LENGTH 1.
    FIELD-SYMBOLS:
      <ls_account> TYPE bapimepoaccount,
      <ls_item>    TYPE mmpurui_pr_items_sty.

**********************END OF DECLARATION BLOCK************************

**********************DATA PREPARETION BLOCK**************************
*** Prepare header data
    READ TABLE it_pr_items_set INDEX 1 ASSIGNING <ls_item>.
    IF sy-subrc GT 0.
      RETURN.
    ENDIF.
*
* determine correct document type based on PReq data
* requires note 1718114
    TRY.
        MOVE-CORRESPONDING <ls_item> TO ls_eban.            "#EC *
        GET BADI lo_badi.
        CALL BADI lo_badi->bsart_determine
          EXPORTING
            is_eban   = ls_eban
            iv_gpstyp = lv_gpstyp
          CHANGING
            cv_bsart  = lv_bsart.
        IF lv_bsart IS INITIAL.
          lv_bsart = if_ex_me_bsart_determine=>mc_bsart_nb.
        ENDIF.
      CATCH cx_mmpur_not_found.
        lv_bsart = if_ex_me_bsart_determine=>mc_bsart_nb.
    ENDTRY.
    lo_cppr = cl_mmpur_ui_cppr=>get_instance( ).
    CREATE OBJECT lo_db.

    CREATE OBJECT me->mo_const. "1791579
*
* read data associated to document type (T161)
    TRY.
        ls_t161 = lo_db->get_t161( im_bsart = lv_bsart
                                   im_bstyp = me->mo_const->bstyp_f ).
      CATCH cx_mmpur_not_found.
        CLEAR: ls_t161, lv_bsart.
    ENDTRY.
*
* fill the header structure.
    ls_header-doc_type   = lv_bsart.
    ls_headerx-doc_type  = me->mo_const->yes.
    ls_header-vendor     = iv_sos.
    ls_headerx-vendor    = me->mo_const->yes.
    ls_header-purch_org  = <ls_item>-ekorg.
    ls_headerx-purch_org = me->mo_const->yes.
    ls_header-pur_group  = <ls_item>-ekgrp.
    ls_headerx-pur_group = me->mo_const->yes.

    CLEAR lv_item_no.
    LOOP AT it_pr_items_set ASSIGNING <ls_item>.

      IF <ls_item>-banfn IS NOT INITIAL AND
        <ls_item>-bnfpo IS NOT INITIAL.
        ls_item-preq_no    = <ls_item>-banfn.
        ls_item-preq_item  = <ls_item>-bnfpo.
        ls_itemx-preq_no   = me->mo_const->yes.
        ls_itemx-preq_item = me->mo_const->yes.
      ENDIF.
*
* create item entry and set the itemx entry
      ls_item-po_item    = lv_item_no = lv_item_no + ls_t161-pincr.
      ls_itemx-po_item   = ls_item-po_item.
      ls_itemx-po_itemx  = me->mo_const->yes.
*
      IF <ls_item>-knttp IS NOT INITIAL.
        ls_item-acctasscat  = <ls_item>-knttp.
        ls_itemx-acctasscat = me->mo_const->yes.
      ENDIF.
*
* If Service item.
      IF <ls_item>-pstyp EQ me->mo_const->pstyp_9.
        ls_item-item_cat  = <ls_item>-pstyp.
        ls_itemx-item_cat = me->mo_const->yes.
*
        me->get_pr_service_data(
                EXPORTING iv_packno       = <ls_item>-packno
                IMPORTING et_service_data = lt_services1 ).
*
* Extend for service line accounting info
        lo_cppr->get_service_line_info(
               EXPORTING im_po_number         = <ls_item>-banfn
                         iv_item_no           = <ls_item>-bnfpo
               IMPORTING ex_et_srv_acc_values = lt_srv_acc1
                         ex_et_srv_acc        = lt_acc_tmp ).
*
        me->replace_packno( EXPORTING iv_packno  = <ls_item>-packno
                                IMPORTING ev_packno  = ls_item-pckg_no
                                CHANGING  ct_service = lt_services1
                                          ct_account = lt_srv_acc1 ).
*
        ls_itemx-pckg_no = me->mo_const->yes.
*
        IF lines( lt_services1 ) GE 1.
          INSERT LINES OF lt_services1 INTO TABLE lt_services.
        ENDIF.
*
        IF lines( lt_srv_acc1 ) GE 1.
          INSERT LINES OF lt_srv_acc1 INTO TABLE lt_srv_acc.
        ENDIF.
*
        IF lines( lt_acc_tmp ) GE 1.
* generate change toolbar structure (POACCOUNTX)
          lo_util = cl_mmpur_utilities=>get_instance( ).
          LOOP AT lt_acc_tmp ASSIGNING <ls_account>.
            CLEAR ls_accountx.
            <ls_account>-po_item = ls_item-po_item.
            INSERT <ls_account> INTO TABLE lt_account.
            lo_util->set_x( EXPORTING im_data = <ls_account>
                            IMPORTING ex_data = ls_accountx ).
            INSERT ls_accountx INTO TABLE lt_accountx.
          ENDLOOP.
        ENDIF.
*
      ENDIF.
*
      INSERT: ls_item  INTO TABLE lt_item,
              ls_itemx INTO TABLE lt_itemx.
*
      CLEAR: ls_item, ls_itemx.

    ENDLOOP.

*--------------------------------------------------------------------*
* Call PurchaseOrder.CreateFromData1 to create a Purchase Order
*--------------------------------------------------------------------*
    SET EXTENDED CHECK OFF.                                 "#EC *
* Call PO BAPI
    IF lines( lt_itemx ) GE 1.
      IF iv_commit_data IS INITIAL.
        lv_testrun = me->mo_const->yes.
      ENDIF.
      ls_header-created_by = me->gv_creator.
      ls_headerx-created_by = abap_true.
      ls_header-memory = abap_true.
      ls_headerx-memory = abap_true.
      ls_header-memorytype = 'H'.
      ls_headerx-memorytype = abap_true.

      CALL FUNCTION 'BAPI_PO_CREATE1'
        DESTINATION 'NONE'
        EXPORTING
          poheader          = ls_header                       "#EC ENHOK
          poheaderx         = ls_headerx                      "#EC ENHOK
          testrun           = lv_testrun
          memory_complete   = abap_true
          memory_uncomplete   = abap_true
        IMPORTING
          exppurchaseorder  = lv_po_number
        TABLES
          return            = et_return_messages
          poitem            = lt_item                         "#EC *
          poitemx           = lt_itemx                        "#EC *
          poservices        = lt_services                     "#EC *
          poaccount         = lt_account                      "#EC *
          poaccountx        = lt_accountx                     "#EC *
          posrvaccessvalues = lt_srv_acc.                     "#EC *
*
* if PO is created COMMIT else ROLLBACK
      IF lv_po_number IS INITIAL OR lv_testrun EQ me->mo_const->yes.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
          DESTINATION 'NONE'.
        CLEAR ev_po_created_status.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          DESTINATION 'NONE'.
        ev_po_created_status = me->mo_const->yes.
      ENDIF.
    ENDIF.
    SET EXTENDED CHECK ON.                                  "#EC *

  ENDMETHOD.


  method GET_DUMMY_PACKNO.
      rv_packno = me->mv_packno = me->mv_packno + 1.
  endmethod.


  METHOD get_po_number.
    DATA :
      ls_pr_item   TYPE mmpurui_pr_items_sty,
      ls_bapi_item TYPE bapimereqitem,
      lt_bapi_item TYPE ty_bapimereqitem
      .

    READ TABLE it_pr_items INTO ls_pr_item INDEX 1.

    CALL FUNCTION 'BAPI_PR_GETDETAIL'
      EXPORTING
        number = ls_pr_item-banfn
*       ACCOUNT_ASSIGNMENT          = ' '
*       ITEM_TEXT                   = ' '
*       HEADER_TEXT                 = ' '
*       DELIVERY_ADDRESS            = ' '
*       VERSION                     = ' '
*       SC_COMPONENTS               = ' '
*       SERIAL_NUMBERS              = ' '
*       SERVICES                    = ' '
*     IMPORTING
*       PRHEADER                    =
      TABLES
*       RETURN =
        pritem = lt_bapi_item
*       PRACCOUNT                   =
*       PRADDRDELIVERY              =
*       PRITEMTEXT                  =
*       PRHEADERTEXT                =
*       EXTENSIONOUT                =
*       ALLVERSIONS                 =
*       PRCOMPONENTS                =
*       SERIALNUMBERS               =
*       SERVICEOUTLINE              =
*       SERVICELINES                =
*       SERVICELIMIT                =
*       SERVICECONTRACTLIMITS       =
*       SERVICEACCOUNT              =
*       SERVICELONGTEXTS            =
      .
    READ TABLE lt_bapi_item INTO ls_bapi_item
      WITH KEY preq_item = ls_pr_item-bnfpo.


    APPEND ls_bapi_item-po_number TO me->gt_ebeln.
  ENDMETHOD.


  METHOD get_pr_detail.
    DATA :
      ls_bapimereqheader TYPE bapimereqheader,
      ls_item            TYPE bapimereqitem,
      lt_item            TYPE ty_bapimereqitem,
      lt_item2           TYPE ty_bapimereqitem,
      ls_item_vendor     TYPE ts_item_flief.

    CALL FUNCTION 'BAPI_PR_GETDETAIL'
      EXPORTING
        number   = me->gv_banfn
*       ACCOUNT_ASSIGNMENT          = ' '
*       ITEM_TEXT                   = ' '
*       HEADER_TEXT                 = ' '
*       DELIVERY_ADDRESS            = ' '
*       VERSION  = ' '
*       SC_COMPONENTS               = ' '
*       SERIAL_NUMBERS              = ' '
*       SERVICES = ' '
      IMPORTING
        prheader = ls_bapimereqheader
      TABLES
*       RETURN   =
        pritem   = lt_item
*       PRACCOUNT                   =
*       PRADDRDELIVERY              =
*       PRITEMTEXT                  =
*       PRHEADERTEXT                =
*       EXTENSIONOUT                =
*       ALLVERSIONS                 =
*       PRCOMPONENTS                =
*       SERIALNUMBERS               =
*       SERVICEOUTLINE              =
*       SERVICELINES                =
*       SERVICELIMIT                =
*       SERVICECONTRACTLIMITS       =
*       SERVICEACCOUNT              =
*       SERVICELONGTEXTS            =
      .

    SORT lt_item BY fixed_vend.
    LOOP AT lt_item INTO ls_item WHERE delete_ind EQ ''
                                 AND rel_ind EQ ''.
      IF ls_item_vendor-vendor IS INITIAL.
        ls_item_vendor-vendor = ls_item-fixed_vend .
      ENDIF.
      IF  me->gv_creator IS INITIAL.
        me->gv_creator = ls_item-created_by.
      ENDIF.

      IF ls_item_vendor-vendor EQ ls_item-fixed_vend .
        APPEND ls_item TO ls_item_vendor-items.
      ELSE.
*  new vendor in the PR
        APPEND ls_item_vendor TO me->gt_items_per_vendor.
        CLEAR ls_item_vendor.
        ls_item_vendor-vendor = ls_item-fixed_vend .
        APPEND ls_item TO ls_item_vendor-items.
      ENDIF.
    ENDLOOP.
* Add the last line
    APPEND ls_item_vendor TO me->gt_items_per_vendor.

  ENDMETHOD.


  method GET_PR_SERVICE_DATA.
  DATA ls_esll      TYPE          esll.
  DATA lt_esll      TYPE TABLE OF esll.
  DATA lt_esll_tty  TYPE          bapiesllc_tp.
  DATA ls_esll_sty  TYPE          bapiesllc.

  CALL FUNCTION 'MS_READ_SERVICES'
    EXPORTING
      i_hpackno = iv_packno
    TABLES
      t_esll    = lt_esll.

  LOOP AT lt_esll INTO ls_esll.

    CLEAR ls_esll_sty.

    ls_esll_sty-pckg_no         =   ls_esll-packno." + 10.
    ls_esll_sty-line_no         =   ls_esll-introw.
    ls_esll_sty-ext_line        =   ls_esll-extrow.
    ls_esll_sty-gr_price        =   ls_esll-tbtwr.
    ls_esll_sty-outl_ind        =   ls_esll-package.
    ls_esll_sty-delete_ind      =   ls_esll-del.
    ls_esll_sty-service         =   ls_esll-srvpos.
    ls_esll_sty-subpckg_no      =   ls_esll-sub_packno." + 10.
    ls_esll_sty-serv_type       =   ls_esll-lbnum.
    ls_esll_sty-edition         =   ls_esll-ausgb.
    ls_esll_sty-ssc_item        =   ls_esll-stlvpos.
    ls_esll_sty-ext_serv        =   ls_esll-extsrvno.
    ls_esll_sty-quantity        =   ls_esll-menge.
    ls_esll_sty-base_uom        =   ls_esll-meins.
    ls_esll_sty-ovf_tol         =   ls_esll-uebto.
    ls_esll_sty-ovf_unlim       =   ls_esll-uebtk.
    ls_esll_sty-price_unit      =   ls_esll-peinh.
    ls_esll_sty-from_line       =   ls_esll-frompos.
    ls_esll_sty-to_line         =   ls_esll-topos.
    ls_esll_sty-short_text      =   ls_esll-ktext1.
    ls_esll_sty-distrib         =   ls_esll-vrtkz.
    ls_esll_sty-pers_no         =   ls_esll-pernr.
    ls_esll_sty-wagetype        =   ls_esll-lgart.
    ls_esll_sty-pln_pckg        =   ls_esll-packno.
    ls_esll_sty-pln_line        =   ls_esll-introw.
    ls_esll_sty-con_pckg        =   ls_esll-knt_packno.
    ls_esll_sty-con_line        =   ls_esll-knt_introw.
    ls_esll_sty-tmp_pckg        =   ls_esll-tmp_packno.
    ls_esll_sty-tmp_line        =   ls_esll-tmp_introw.
    ls_esll_sty-ssc_lim         =   ls_esll-stlv_lim.
    ls_esll_sty-limit_line      =   ls_esll-limit_row.
    ls_esll_sty-target_val      =   ls_esll-zielwert.
    ls_esll_sty-basline_no      =   ls_esll-alt_introw.
    ls_esll_sty-basic_line      =   ls_esll-basic.
    ls_esll_sty-alternat        =   ls_esll-alternat.
    ls_esll_sty-bidder          =   ls_esll-bidder.
    ls_esll_sty-supp_line       =   ls_esll-supple.
    ls_esll_sty-open_qty        =   ls_esll-freeqty.
    ls_esll_sty-inform          =   ls_esll-inform.
    ls_esll_sty-blanket         =   ls_esll-pausch.
    ls_esll_sty-eventual        =   ls_esll-eventual.
    ls_esll_sty-tax_code        =   ls_esll-mwskz.
    ls_esll_sty-taxjurcode      =   ls_esll-txjcd.
    ls_esll_sty-price_chg       =   ls_esll-prs_chg.
    ls_esll_sty-matl_group      =   ls_esll-matkl.
    ls_esll_sty-date            =   ls_esll-sdate.
    ls_esll_sty-begintime       =   ls_esll-begtime.
    ls_esll_sty-endtime         =   ls_esll-endtime.
    ls_esll_sty-extpers_no      =   ls_esll-persext.
    ls_esll_sty-formula         =   ls_esll-formelnr.
    ls_esll_sty-form_val1       =   ls_esll-frmval1.
    ls_esll_sty-form_val2       =   ls_esll-frmval2.
    ls_esll_sty-form_val3       =   ls_esll-frmval3.
    ls_esll_sty-form_val4       =   ls_esll-frmval4.
    ls_esll_sty-form_val5       =   ls_esll-frmval5.
    ls_esll_sty-userf1_num      =   ls_esll-userf1_num.
    ls_esll_sty-userf2_num      =   ls_esll-userf2_num.
    ls_esll_sty-userf1_txt      =   ls_esll-userf1_txt.
    ls_esll_sty-userf2_txt      =   ls_esll-userf2_txt.
    ls_esll_sty-extrefkey       =   ls_esll-extrefkey.
    ls_esll_sty-per_sdate       =   ls_esll-per_sdate.
    ls_esll_sty-per_edate       =   ls_esll-per_edate.

    APPEND ls_esll_sty TO lt_esll_tty.

  ENDLOOP.

  APPEND LINES OF lt_esll_tty TO et_service_data.
  endmethod.


  METHOD map_pr_2_bapi.
    DATA :
      ls_vendor_items TYPE ts_item_flief,
      ls_item         TYPE bapimereqitem,
      lt_item_cl      TYPE mmpurui_pr_items_tty,
      ls_item_cl      TYPE mmpurui_pr_items_sty,
      lv_vendor       TYPE flief,
      lt_bapiret2     TYPE bapirettab,
      ls_bapiret2     TYPE bapiret2,
      lv_stat         TYPE boolean.

* for each vendor in the PR
    LOOP AT me->gt_items_per_vendor INTO ls_vendor_items.
      lv_vendor = ls_vendor_items-vendor.
* loop at each items
      LOOP AT ls_vendor_items-items INTO ls_item.
        ls_item_cl-matnr = ls_item-material.
        ls_item_cl-txz01 = ls_item-short_text.
        ls_item_cl-matkl = ls_item-matl_group.
        ls_item_cl-banfn = me->gv_banfn.
        ls_item_cl-preis = ls_item-value_item.
        ls_item_cl-lfdat = ls_item-deliv_date.
        ls_item_cl-bnfpo = ls_item-preq_item.
        ls_item_cl-flief = ls_item-fixed_vend.
        ls_item_cl-meins = ls_item-unit.
        ls_item_cl-waers = ls_item-currency.
        ls_item_cl-ekgrp = ls_item-pur_group.
        ls_item_cl-ekorg = ls_item-purch_org.
        ls_item_cl-pstyp = ls_item-item_cat.
        ls_item_cl-knttp = ls_item-acctasscat.
        ls_item_cl-packno = ls_item-pckg_no.

        APPEND ls_item_cl TO lt_item_cl.
        CLEAR ls_item.
      ENDLOOP.

* Create the PO
      CALL METHOD me->create_po
        EXPORTING
          it_pr_items_set      = lt_item_cl
          iv_sos               = lv_vendor
          iv_commit_data       = abap_true
        IMPORTING
          et_return_messages   = lt_bapiret2
          ev_po_created_status = lv_stat.
* If PO created get the PO Number
      if lv_stat eq abap_true.
        me->get_po_number( lt_item_cl ).
      endif.
      CLEAR ls_vendor_items.
    ENDLOOP.
  ENDMETHOD.


  method REPLACE_PACKNO.
*--------------------------------------------------------------------*
* Introduced by note 1573047
*--------------------------------------------------------------------*

* define local data objects
  DATA: lv_packno TYPE packno,
        ls_packno TYPE type_s_packno.

  FIELD-SYMBOLS:
        <ls_service> TYPE bapiesllc,
        <ls_account> TYPE bapiesklc.

  CREATE OBJECT me->mo_const.   "1791579

* check if registered
  READ TABLE me->mt_package WITH KEY dummy = iv_packno
                            TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    RETURN.
  ENDIF.
* PCKG_NO & SUBPCKG_NO substitution
  LOOP AT ct_service ASSIGNING <ls_service> WHERE pckg_no = iv_packno.
    ev_packno = lv_packno = me->get_dummy_packno( ).
    ls_packno-packno = <ls_service>-pckg_no.
    ls_packno-dummy  = lv_packno.
    INSERT ls_packno INTO TABLE me->mt_package.
    LOOP AT ct_account ASSIGNING <ls_account>.
      CHECK <ls_account>-pckg_no EQ <ls_service>-pckg_no.
      <ls_account>-pckg_no = lv_packno.
    ENDLOOP.
    <ls_service>-pckg_no = lv_packno.

    CHECK <ls_service>-subpckg_no IS NOT INITIAL.
    me->replace_packno( EXPORTING iv_packno  = <ls_service>-subpckg_no
                                  iv_subpack = me->mo_const->yes
                        IMPORTING ev_packno  = <ls_service>-subpckg_no
                        CHANGING  ct_service = ct_service
                                  ct_account = ct_account ).
  ENDLOOP.

  endmethod.
ENDCLASS.
