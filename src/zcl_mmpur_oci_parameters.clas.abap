class ZCL_MMPUR_OCI_PARAMETERS definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_OCI_PARAMETERS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_OCI_PARAMETERS IMPLEMENTATION.


  method IF_MMPUR_OCI_PARAMETERS~MODIFY_PARAMETERS.

if IV_CATALOGID eq 'OFFICEDEPOT'.
*    break-point.

else.
*  break-point.
endif.
  endmethod.
ENDCLASS.
