class ZCL_MMPUR_OCI_S4H_BRF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_OCI_ITEM_TRANSFER .
protected section.
private section.

  methods CHANGE_OCI
    importing
      !IV_CAT_ID type MM_OCI_WEB_SERVICE_ID
    changing
      !CS_OCI_ITEM type MMPUR_OCI_CAT_RETURN_TYPE .
ENDCLASS.



CLASS ZCL_MMPUR_OCI_S4H_BRF IMPLEMENTATION.


  method CHANGE_OCI.
************************************************************************************************************************************
*  L'application BRF+ CDLG/WKB_MMPUR_OCI - 005056B2ACCD1ED88DA078BE7225C124
*  Fonction /CDLG/MMPUR_OCI_CHANGE_VALUE - 005056B2ACCD1ED88DA086242E9AA12D

************************************************************************************************************************************
CONSTANTS:lv_function_id TYPE if_fdt_types=>id VALUE '005056B2ACCD1ED88DA086242E9AA12D'.
  DATA:lv_timestamp TYPE timestamp,
       lt_name_value TYPE abap_parmbind_tab,
       ls_name_value TYPE abap_parmbind,
       lr_data TYPE REF TO data,
       lx_fdt TYPE REF TO cx_fdt,
       la_is_oci_item TYPE MMPUR_OCI_CAT_RETURN_TYPE,
       la_iv_bbp_ws_service_id TYPE if_fdt_types=>element_text,
       la_iv_sysid TYPE if_fdt_types=>element_text.

  FIELD-SYMBOLS <la_any> TYPE any.
****************************************************************************************************
* Au sein d'un cycle de traitement, tous les appels de méthode appelant la même fonction doivent utiliser le même horodatage.
* Pour les appels suivants de la même fonction, il est conseillé d'exécuter tous les appels avec le même horodatage.
* Cela permet d'améliorer la performance du système.
****************************************************************************************************
* Si vous utilisez des structures ou des tables sans liaison du Dictionnaire ABAP, vous devez créer les différents types
* vous-même. Insérez le type de données adapté dans la ligne correspondante du code source.
****************************************************************************************************
  GET TIME STAMP FIELD lv_timestamp.
****************************************************************************************************
* Traiter la fonction sans enregistrement des données trace, transférer éléments de données de contexte par table des noms/des valeurs
****************************************************************************************************
* Préparer traitement de fonction :
****************************************************************************************************
* Faites convertir vos données par BRFplus avec le type BRFplus requis.
* Comme l'objet de données est lié à un type du Dictionnaire ABAP, transférez une variable de ce type pour améliorer la performance.
* Si vous transférez une variable de ce type, affichez-le en transférant "abap_true" pour le paramètre "iv_has_ddic_binding".
****************************************************************************************************
  ls_name_value-name = 'IS_OCI_ITEM'.
  la_IS_OCI_ITEM = cs_oci_item..
  GET REFERENCE OF la_IS_OCI_ITEM INTO lr_data.
  cl_fdt_function_process=>move_data_to_data_object( EXPORTING ir_data             = lr_data
                                                               iv_function_id      = lv_function_id
                                                               iv_data_object      = '005056B2ACCD1ED88DA089DD2069812D' "IS_OCI_ITEM
                                                               iv_timestamp        = lv_timestamp
                                                               iv_trace_generation = abap_false
                                                               iv_has_ddic_binding = abap_true
                                                     IMPORTING er_data             = ls_name_value-value ).
  INSERT ls_name_value INTO TABLE lt_name_value.
****************************************************************************************************
  ls_name_value-name = 'IV_BBP_WS_SERVICE_ID'.
   la_IV_BBP_WS_SERVICE_ID = iv_cat_id.
  GET REFERENCE OF la_IV_BBP_WS_SERVICE_ID INTO lr_data.
  ls_name_value-value = lr_data.
  INSERT ls_name_value INTO TABLE lt_name_value.
****************************************************************************************************
  ls_name_value-name = 'IV_SYSID'.
   la_IV_SYSID = SY-SYSID.
  GET REFERENCE OF la_IV_SYSID INTO lr_data.
  ls_name_value-value = lr_data.
  INSERT ls_name_value INTO TABLE lt_name_value.
****************************************************************************************************
* Créer objet de données pour sauvegarder la valeur de résultat après le traitement de la fonction
* Vous pouvez ignorer l'appel suivant si vous avez déjà déterminer une
* variable pour le résultat. Remplacez également le paramètre
* EA_RESULT dans l'appel de méthode CL_FDT_FUNCTION_PROCESS=>PROCESS
* avec la variable souhaitée.
****************************************************************************************************
  cl_fdt_function_process=>get_data_object_reference( EXPORTING iv_function_id      = lv_function_id
                                                                iv_data_object      = '_V_RESULT'
                                                                iv_timestamp        = lv_timestamp
                                                                iv_trace_generation = abap_false
                                                      IMPORTING er_data             = lr_data ).
  ASSIGN lr_data->* TO <la_any>.
  TRY.
      cl_fdt_function_process=>process( EXPORTING iv_function_id = lv_function_id
                                                  iv_timestamp   = lv_timestamp
                                        IMPORTING ea_result      = cs_oci_item
                                        CHANGING  ct_name_value  = lt_name_value ).
      CATCH cx_fdt into lx_fdt.
****************************************************************************************************
* Vous pouvez contrôler CX_FDT->MT_MESSAGE pour la gestion des erreurs.
****************************************************************************************************
  ENDTRY.

  endmethod.


  METHOD if_mmpur_oci_item_transfer~enrich_item_data.
    DATA ls_punchout_items TYPE  mmpur_oci_catalog_item.
    DATA lt_items TYPE mmpur_oci_catalog_item_t.
    DATA : lo_class TYPE REF TO /cdlg/mmpur_oci.
    DATA : ls_oci TYPE mmpur_oci_cat_return_type.

    CREATE OBJECT lo_class.

    LOOP AT ct_punchout_items INTO ls_punchout_items.
      MOVE-CORRESPONDING ls_punchout_items TO ls_oci.
      me->change_oci( EXPORTING iv_cat_id = ls_punchout_items-service_id CHANGING cs_oci_item = ls_oci   ).
      MOVE-CORRESPONDING ls_oci TO ls_punchout_items.
      APPEND ls_punchout_items TO lt_items.
    ENDLOOP.
    ct_punchout_items = lt_items .

  ENDMETHOD.
ENDCLASS.
