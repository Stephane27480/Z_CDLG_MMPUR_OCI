class ZCL_MMPUR_CATALOG_ENRICH_DATA definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_CAT_ENRICH_DATA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_CATALOG_ENRICH_DATA IMPLEMENTATION.


  method IF_MMPUR_CAT_ENRICH_DATA~ENRICH_ITEM_DATA.
    BREAK-POINT.
  endmethod.
ENDCLASS.
