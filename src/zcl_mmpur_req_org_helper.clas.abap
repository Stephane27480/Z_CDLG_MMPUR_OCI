class ZCL_MMPUR_REQ_ORG_HELPER definition
  public
  final
  create public .

public section.

  methods GET_PLANT_DATA
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_PLANT type WERKS_D .
  methods GET_MATERIAL_GROUP
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_MATGRP type MATKL .
  methods GET_PURCHCASING_GROUP
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_PGROUP type EKGRP .
  methods GET_ACC_ASSGNMENT_CATEGORY
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_ACC_CAT type KNTTP .
  methods GET_ITEM_TYPE
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_ITMTYP type PSTYP .
  methods GET_DOCUMENT_TYPE
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_DOCUMENT_TYPE type BSART .
  methods GET_ASSET_SUBNUMBER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_ASSETSUB type ANLN2 .
  methods GET_COMPANY_CODE
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_BUKRS type BUKRS .
  methods GET_COST_CENTER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_KOSTL type KOSTL .
  methods GET_PURCHASING_ORGANISATION
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_EKORG type EKORG .
  methods GET_GL_ACC_NUMBER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_SAKNR type SAKNR .
  methods GET_NETWORK_NUMBER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_NPLNR type NPLNR .
  methods GET_ORDER_NUMBER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_AUFNR type AUFNR .
  methods GET_WBS_ELEMENT
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_WBS_ELEMENT type PS_POSID_EDIT .
  methods GET_CURRENCY
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_WAERS type WAERS .
  methods GET_CATALOGS
    importing
      !IV_USER type SYUNAME
    exporting
      !ET_CATALOGS type CL_MMPUR_READ_ORG_DATA=>TT_PT1222 .
  methods GET_CATVIEW
    importing
      !IV_USER type SYUNAME
    exporting
      !ET_CATVIEWS type CL_MMPUR_READ_ORG_DATA=>TT_PT1222 .
  methods GET_SALES_ORDER
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_SALESORDER type VBELN .
  methods GET_SALES_ORDER_ITEM
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_SALESODER_ITEM type POSNR_VA .
  methods GET_PRJ_NTW_INTERNALID
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_PRJNTW_INTID type CO_AUFPL .
protected section.
private section.

  methods GET_DELIVERY_DATE
    importing
      !IV_USER type SYUNAME
    exporting
      !EV_DELIVERY_DATE type LFDAT .
ENDCLASS.



CLASS ZCL_MMPUR_REQ_ORG_HELPER IMPLEMENTATION.


  METHOD GET_ACC_ASSGNMENT_CATEGORY.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'KNTTP'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_acc_cat = lv_attrib_value.

  ENDMETHOD.


  METHOD GET_ASSET_SUBNUMBER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'ASSETSUB'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_assetsub = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_CATALOGS.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute_multiple
      EXPORTING
        iv_attribute_name = 'CATALOG'
        iv_user     = iv_user
      IMPORTING
         et_value           = et_catalogs.


  ENDMETHOD.


  METHOD get_catview.
    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute_multiple
      EXPORTING
        iv_attribute_name = 'CATVIEW'
        iv_user           = iv_user
      IMPORTING
        et_value          = et_catviews.

  ENDMETHOD.


  METHOD GET_COMPANY_CODE.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'BUKRS'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_bukrs = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_COST_CENTER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'COSTCENTER'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_kostl = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_CURRENCY.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'WAERS'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_waers = lv_attrib_value.


  ENDMETHOD.


  method GET_DELIVERY_DATE.

*    DATA lv_attrib_value TYPE om_attrval.
*
*    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
*      EXPORTING
*        iv_attribute_name = 'WERKS'
*        iv_user     = iv_user
*      IMPORTING
*        ev_value          = lv_attrib_value.
*
*    ev_plant = lv_attrib_value.


  endmethod.


  METHOD GET_DOCUMENT_TYPE.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'BSART'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    EV_DOCUMENT_TYPE = lv_attrib_value.

  ENDMETHOD.


  METHOD GET_GL_ACC_NUMBER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'GLACCT'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_saknr = lv_attrib_value.


  ENDMETHOD.


  method GET_ITEM_TYPE.
  endmethod.


  method GET_MATERIAL_GROUP.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'MATKL'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_matgrp = lv_attrib_value.


  endmethod.


  METHOD GET_NETWORK_NUMBER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'NETWORK'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_nplnr = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_ORDER_NUMBER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'ORDER'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_aufnr = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_PLANT_DATA.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'WERKS'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_plant = lv_attrib_value.

  ENDMETHOD.


  method GET_PRJ_NTW_INTERNALID.
*    DATA lv_attrib_value TYPE om_attrval.
*
*    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
*      EXPORTING
*        iv_attribute_name = 'WERKS'
*        iv_user     = iv_user
*      IMPORTING
*        ev_value          = lv_attrib_value.
*
*    ev_plant = lv_attrib_value.

  endmethod.


  METHOD GET_PURCHASING_ORGANISATION.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'EKORG'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_ekorg = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_PURCHCASING_GROUP.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'RESPPGRP'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_pgroup = lv_attrib_value.


  ENDMETHOD.


  METHOD GET_SALES_ORDER.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'SALESORDER'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_salesorder = lv_attrib_value.


  ENDMETHOD.


  method GET_SALES_ORDER_ITEM.

    DATA lv_attrib_value TYPE om_attrval.

      CALL METHOD zcl_mmpur_read_org_data=>read_attribute
        EXPORTING
          iv_attribute_name = 'SALESORITM'
        iv_user     = iv_user
        IMPORTING
          ev_value          = lv_attrib_value.

     EV_SALESODER_ITEM = lv_attrib_value.

 endmethod.


 METHOD GET_WBS_ELEMENT.

    DATA lv_attrib_value TYPE om_attrval.

    CALL METHOD zcl_mmpur_read_org_data=>read_attribute
      EXPORTING
        iv_attribute_name = 'WBSELEMENT'
        iv_user     = iv_user
      IMPORTING
        ev_value          = lv_attrib_value.

    ev_wbs_element = lv_attrib_value.


  ENDMETHOD.
ENDCLASS.
