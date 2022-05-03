class ZCL_MMPUR_REQ_DEFAULT_DATA definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_REQ_DEFAULT_DATA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_REQ_DEFAULT_DATA IMPLEMENTATION.


  METHOD if_mmpur_req_default_data~default_data.
    DATA ls_catalog TYPE mmpur_req_s_default_cat    .
    DATA :  lo_helper TYPE REF TO zcl_mmpur_req_org_helper.

    CREATE OBJECT lo_helper.
    lo_helper->get_plant_data( EXPORTING iv_user = sy-uname IMPORTING ev_plant = cs_item-plant ).
    lo_helper->get_material_group( EXPORTING iv_user = sy-uname IMPORTING ev_matgrp = cs_item-materialgroup ).
    lo_helper->get_purchcasing_group( EXPORTING iv_user = sy-uname IMPORTING ev_pgroup = cs_item-purchasinggroup ).
    lo_helper->GET_ACC_ASSGNMENT_CATEGORY( EXPORTING iv_user = sy-uname IMPORTING EV_ACC_CAT = cs_item-accountassignmentcategory ).
    lo_helper->GET_ITEM_TYPE( EXPORTING iv_user = sy-uname IMPORTING EV_ITMTYP = cs_item-itemcategory ).
    lo_helper->GET_DOCUMENT_TYPE( EXPORTING iv_user = sy-uname IMPORTING EV_DOCUMENT_TYPE = cs_item-documenttype ).
    lo_helper->GET_ASSET_SUBNUMBER( EXPORTING iv_user = sy-uname IMPORTING EV_ASSETSUB = cs_item-assetsubnumber ).
    lo_helper->GET_COMPANY_CODE( EXPORTING iv_user = sy-uname IMPORTING EV_BUKRS = cs_item-companycode ).
    lo_helper->GET_COST_CENTER( EXPORTING iv_user = sy-uname IMPORTING EV_KOSTL = cs_item-costcenter ).
    lo_helper->GET_PURCHASING_ORGANISATION( EXPORTING iv_user = sy-uname IMPORTING EV_EKORG = cs_item-purchasingorganisation ).
    lo_helper->GET_GL_ACC_NUMBER( EXPORTING iv_user = sy-uname IMPORTING EV_SAKNR = cs_item-glaccountnumber ).
    lo_helper->GET_NETWORK_NUMBER( EXPORTING iv_user = sy-uname IMPORTING EV_NPLNR = cs_item-networknumber ).
    lo_helper->GET_ORDER_NUMBER( EXPORTING iv_user = sy-uname IMPORTING EV_AUFNR = cs_item-ordernumber ).
*    lo_helper->GET_WBS_ELEMENT( EXPORTING iv_user = sy-uname IMPORTING EV_WBS_ELEMENT = cs_item-wbselement ).
    lo_helper->GET_CURRENCY( EXPORTING iv_user = sy-uname IMPORTING EV_WAERS = cs_item-currency ).
    lo_helper->GET_SALES_ORDER( EXPORTING iv_user = sy-uname IMPORTING EV_SALESORDER = cs_item-salesorder ).
    lo_helper->GET_SALES_ORDER_ITEM( EXPORTING iv_user = sy-uname IMPORTING EV_SALESODER_ITEM = cs_item-salesorderitem ).
*    lo_helper->GET_DELIVERY_DATE( EXPORTING iv_user = sy-uname IMPORTING EV_DELIVERY_DATE = cs_item-deliverydate ).
    lo_helper->GET_CATALOGS( EXPORTING iv_user = sy-uname IMPORTING ET_CATALOGS = ct_catalogs ).

*    APPEND ls_catalog TO ct_catalogs.
  ENDMETHOD.
ENDCLASS.
