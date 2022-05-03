class ZCL_MMPUR_OCI_ITEM_TRANSFER definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_OCI_ITEM_TRANSFER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_OCI_ITEM_TRANSFER IMPLEMENTATION.


  METHOD if_mmpur_oci_item_transfer~enrich_item_data.
    DATA ls_punchout_items TYPE  mmpur_oci_catalog_item.
    DATA lt_items TYPE mmpur_oci_catalog_item_t.
    DATA : lo_class TYPE REF TO /cdlg/mmpur_oci.
    DATA : ls_oci TYPE mmpur_oci_cat_return_type.

    CREATE OBJECT lo_class.

    LOOP AT ct_punchout_items INTO ls_punchout_items.
      MOVE-CORRESPONDING ls_punchout_items TO ls_oci.
      lo_class->call_oci_change( CHANGING cs_oci_item = ls_oci ).
      MOVE-CORRESPONDING ls_oci TO ls_punchout_items.
      APPEND ls_punchout_items TO lt_items.
    ENDLOOP.
    ct_punchout_items = lt_items .

  ENDMETHOD.
ENDCLASS.
