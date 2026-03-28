CLASS ze012substitutionwbselement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  meTHODS: backup.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ze012substitutionwbselement IMPLEMENTATION.
  METHOD backup.

*  TD:
*  Introduction
*
*This Technical Specification describes the process of auto populating fields of subordinate WBS element based on the parent WBS element.
*
*
*
*SAP Project System (PS) contains two objects – Project Definition and WBS elements. Project Definitions provide the overall data that is applicable to all WBS elements. While WBS elements master data can be set-up independently. For Vistra, the process
"for creating Projects begin in EPPM where a Portfolio Item is converted one-for-one as a Project in PS when the portfolio item is approved. Certain master data entered in EPPM Portfolio Item will need to be inherited in Project System’s Project Definiti
"on. Additionally, data elements entered in the WBS elements will need to be inherited by all subordinate WBS elements. This enhancement will ensure that certain master data entered in one object are brought into the related objects ensuring data consist
"ency of the master data elements for the objects as well as to ensure that data is only entered once.
*
*
*Enhancement Technical Design
*
*This Technical Specification explains how subordinate WBS elements inherit data from parent WBS elements. Few data elements (responsible cost center, requesting cost center, unit, removal cost justification) from the higher level WBS element should be i
"nherited by the subordinate WBS element when it is created from CJ20n – minimizing the amount of data entry the user must perform.
*
*
*
*A) Inheriting WBS data elements for sub levels.
*
*
*
*EPPM Portfolio Items are created to plan for various project types that will be implemented for the fiscal year or as part of the Long-Range Planning. Certain master data is entered during the set-up of the items which categorizes the plan data by organ
"izational structure, project categories/sub-categories and assignment to the Portfolio Hierarchical Structure.
*
*Some of this data has a natural integration with SAP Project System – such as project description, start and finish dates, etc. However, other data elements such as the custom fields that will be added to the item master data do not have the standard in
"tegration to Project Systems. The data entered in these fields will need to flow to the corresponding Project in PS when the item is converted into Project upon approval of the items. Here are the various fields that will need to be dispositioned by thi
"s enhancement:
*
*
*
*Source
*
*Data Element
*
*Receiver
*
*Data Element
*
*PS – Project Definition
*
*Description
*
*PS – WBS Level 1
*
*Description
*
*PS – WBS Level 1
*
*Responsible Cost Center
*
*PS – WBS Sub Levels
*
*Responsible Cost Center
*
*PS – WBS Level 1
*
*Requesting Cost Center
*
*PS – WBS Sub Levels
*
*Requesting Cost Center
*
*PS – WBS Level 1
*
*Unit
*
*PS – WBS Sub Levels
*
*Unit
*
*PS – WBS Level 1
*
*Removal Cost Justification
*
*PS – WBS Sub Levels
*
*Removal Cost Justification
*
*
*
*B) Substitution rules for Costing sheet assignment
*
*
*
*Below configuration will be done by Functional team.
*
*
*
*Additionally, custom substitution rules will need to be defined to substitute the appropriate costing sheet to be assigned to the account assignment WBS element based on whether the custom field Removal Cost is set to “Yes” and the company code assignme
"nt of the Project/WBS elements. Specifically, the substitution rule needs the following logic:
*
*
*
*Pre-requisite:
*
*Project Profile = Capital
*
*Account Assignment = “X”
*
*
*
*Substitution:
*
*Look-up the company code of the project and substitute the Costing Sheet for the Company Code (CoCd) by looking up the costing sheet assigned in set CoCd Costing Sheets.
*
*Technical Solution Description
*
*Enhancement to populate Description from PS to WBS element level 1.
*
*
*
*Source
*
*Data Element
*
*Receiver
*
*Data Element
*
*PS – Project Definition (PROJ)
*
*Description (POST1)
*
*PS – WBS Level 1 (PRPS)
*
*Description (POST1)
*
*
*
*Use BADI INM_IF_CPPM_SYNCH in Eclipse ADT, write logic in PROCESS_EXTENSIONIN method for fetching the Description from PROJ table and populate the description in WBS element level 1.
*
*
*
*Enhancement to update requesting cost center, requesting controlling area, responsible cost center, responsible controlling area, Unit, Removal cost justification fields to subordinate WBS elements.
*
*
*
*Source
*
*Data Element
*
*Receiver
*
*Data Element
*
*PS – WBS Level 1
*
*Responsible Cost Center (FKSTL)
*
*PS – WBS Sub Levels
*
*Responsible Cost Center (FKSTL)
*
*PS – WBS Level 1
*
*Requesting Cost Center (AKSTL)
*
*PS – WBS Sub Levels
*
*Requesting Cost Center (AKSTL)
*
*PS – WBS Level 1
*
*Unit (ZZ1_UNIT1_PSR)
*
*PS – WBS Sub Levels
*
*Unit (ZZ1_UNIT1_PSR)
*
*PS – WBS Level 1
*
*Removal Cost Justification (ZZ1_RCINDICATORTEXT_PSR)
*
*PS – WBS Sub Levels
*
*Removal Cost Justification (ZZ1_RCINDICATORTEXT_PSR)
*
*
*
*
*
*There is no BADI or customer exit when the WBS creation screen is getting opened.
*
*Therefore, as per further analysis, we need to create an implicit enhancement where we can add the logic to inherit the data (requesting cost center, requesting controlling area, responsible cost center, responsible controlling area, Unit, Removal cost
"justification, Removal Cost Indicator, Actual Project In-Service Date, Legacy Project ID ITC Eligible) from higher level WBS element to current/child WBS element and Inherit Person Responsible number, Person Responsible name, Applicant number, Applicant
" fields from Project to WBS all levels.
*
*Implicit Enhancement name: ZA2R_EP_WBSSUB in report SAPLCJWB
*
*
*
*Defect : FITT-9300 - Unit fiend Reference from ZR2RT_UNIT
*FSDK901953 - FITT:A2R:E069, I067, E012 Unit field reference defect-9300
*
*Defect: FITT-9991 – Flow Person Responsible, Applicant no from Project to WBS levels and all the custom fields from WBS L1 to WBS sub levels
*FSDK902407 - FITT:A2R:E012,E069 Substitution WBS fields,Unit F4 D-9991
*
*
*
*Defect – 9991: As per the defect below fields are included to flow from WBS L1 to sub levels / Project to WBS
*
*
*
*Source
*
*Data Element
*
*Receiver
*
*Data Element
*
*PS – WBS Level 1
*
*
*
*Removal Cost Indicator (ZZ1_REMOVALCOSTINDICAT)
*
*PS – WBS Sub Levels
*
*
*
*Removal Cost Indicator (ZZ1_REMOVALCOSTINDICAT)
*
*PS – WBS Level 1
*
*
*
*Actual Project In-Service Date (ZZ1_ACTUALPROJECTINSER_PSR)
*
*PS – WBS Sub Levels
*
*
*
*Actual Project In-Service Date (ZZ1_ACTUALPROJECTINSER_PSR)
*
*PS – WBS Level 1
*
*
*
*Legacy Project ID (ZZ1_LEGACYPROJECTID_PSR)
*
*PS – WBS Sub Levels
*
*
*
*Legacy Project ID (ZZ1_LEGACYPROJECTID_PSR)
*
*PS – WBS Level 1
*
*
*
*ITC Eligible (ZZ1_ITCELIGIBLE_PSR)
*
*PS – WBS Sub Levels
*
*
*
*ITC Eligible (ZZ1_ITCELIGIBLE_PSR)
*
*PROJ
*
*Person Responsible number (VERNR)
*
*PS – WBS Sub Levels
*
*
*
*Person Responsible number (VERNR)
*
*
*
*PROJ
*
*Person Responsible name (VERNA)
*
*PS – WBS Sub Levels
*
*
*
*Person Responsible name (VERNA)
*
*
*
*PROJ
*
*Applicant number (ASTNR)
*
*PS – WBS Sub Levels
*
*
*
*Applicant number (ASTNR)
*
*
*
*PROJ
*
*Applicant (ASTNA)
*
*PS – WBS Sub Levels
*
*
*
*Applicant (ASTNA)
*
*
*
*
*
*
*   Enhancement Implementation: ZA2R_EP_WBSSUB
*    Program: SAPLCJWB Dynamic Enhancement Point/Section \PR:SAPLCJWB\FO:FKSTL_PBO\SE:BEGIN\EI
*Include FCJWBOEL_FKSTL_PBO
*FORM fkstl_pbo.
*"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form FKSTL_PBO, Start                                                                                                                             A
**$*$-Start: (1) Program: SAPLCJWB include bound-------------------------------------------------$*$*
*ENHANCEMENT 1  ZA2R_EP_WBSSUB.    "active version
*
*************************************************************************
** Written By   : HB311649
** Date         : 07/18/2024
** TR           : FSDK900498
** Ticket Number:
** Description  :E012 Enhancement - Substitution Validations for WBS Element Fields
*************************************************************************
** Amendments:
**Version    |Chg.Date   |User id |Ticket number and brief of change
**----------------------------------------------------------------------*
**----------------------------------------------------------------------*
*
*  DATA: lv_len TYPE i.
*  CONSTANTS: lc_level TYPE prps-stufe VALUE '1'.
*
*  "Fetch cost center, controlling area, unit, rc indicator text fields from PRPS table for previous WBS element
*  "and auto populate them on creation screen of WBS elements
*
*  SELECT SINGLE akokr, akstl, fkokr, fkstl,
*    zz1_unit1_psr, zz1_rcindicatortext_psr,
*    zz1_removalcostindicat_psr, zz1_actualprojectinser_psr,
*    zz1_legacyprojectid_psr, zz1_itceligible_psr,
*    vernr, verna, astnr, astna
*  INTO @DATA(lwa_prps)
*  FROM prps WHERE stufe = @lc_level
*  AND psphi = @prps-psphi.
*
*  IF sy-subrc = 0.
*    IF prps-fkokr IS INITIAL OR prps-fkstl IS INITIAL.
*      prps-fkokr = lwa_prps-fkokr.
*      prps-fkstl = lwa_prps-fkstl.
*    ENDIF.
*
*    IF prps-akokr IS INITIAL OR prps-akstl IS INITIAL.
*      prps-akokr = lwa_prps-akokr.
*      prps-akstl = lwa_prps-akstl.
*    ENDIF.
*
*    "Auto populate all custom fields from WBS L1 to sub levels.
*    IF prps-zz1_unit1_psr IS INITIAL.
*      prps-zz1_unit1_psr = lwa_prps-zz1_unit1_psr.
*    ENDIF.
*
*    IF prps-zz1_rcindicatortext_psr IS INITIAL.
*      prps-zz1_rcindicatortext_psr = lwa_prps-zz1_rcindicatortext_psr.
*    ENDIF.
*                                                            "SOC 9991
*    IF prps-zz1_removalcostindicat_psr IS INITIAL.
*      prps-zz1_removalcostindicat_psr = lwa_prps-zz1_removalcostindicat_psr.
*    ENDIF.
*
*    IF prps-zz1_actualprojectinser_psr IS INITIAL.
*      prps-zz1_actualprojectinser_psr = lwa_prps-zz1_actualprojectinser_psr.
*    ENDIF.
*
*    IF prps-zz1_legacyprojectid_psr IS INITIAL.
*      prps-zz1_legacyprojectid_psr = lwa_prps-zz1_legacyprojectid_psr.
*    ENDIF.
*
*    IF prps-zz1_itceligible_psr IS INITIAL.
*      prps-zz1_itceligible_psr = lwa_prps-zz1_itceligible_psr.
*    ENDIF.
*                                                            "EOC 9991
*  ENDIF.
*
*  "Auto populate Person responsible and Applicant no from Project to WBS.
*  prps-vernr = proj-vernr.
*  prps-verna = proj-verna.
*  prps-astnr = proj-astnr.
*  prps-astna = proj-astna.
*
*
*  CLEAR: lwa_prps.
*
*
*ENDENHANCEMENT.
**$*$-End:   (1) Program: SAPLCJWB include bound-------------------------------------------------$*$

  ENDMETHOD.

ENDCLASS.
