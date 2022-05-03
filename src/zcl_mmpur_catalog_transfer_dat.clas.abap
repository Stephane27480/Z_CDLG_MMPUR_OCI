class ZCL_MMPUR_CATALOG_TRANSFER_DAT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_CATALOG_TRANSFER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_CATALOG_TRANSFER_DAT IMPLEMENTATION.


  METHOD if_mmpur_catalog_transfer~enrich_item_data.
    IF iv_catalog_id EQ 'OFFICEDEPOT'.
      BREAK-POINT .
    ENDIF.
  ENDMETHOD.


  METHOD if_mmpur_catalog_transfer~enrich_pr_item_from_punchout.
    IF ct_punchout_items IS NOT INITIAL.
      BREAK-POINT .
    ENDIF.
  ENDMETHOD.


  method IF_MMPUR_CATALOG_TRANSFER~HANDLE_PRODUCT_RELATIONS.
  endmethod.
ENDCLASS.
