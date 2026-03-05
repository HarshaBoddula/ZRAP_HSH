@EndUserText.label: 'Parameter for Create Travel'
define abstract entity zbi_rap_create_travel
{
    @Consumption.valueHelpDefinition: [{ entity: { name : '/DMO/I_Customer_StdVH', element : 'CustomerID' } } ]
    customer_id : /dmo/customer_id;
    @Consumption.valueHelpDefinition: [{ entity: { name : '/DMO/I_Agency_StdVH', element : 'AgencyID' } } ]
    Agency_id : /dmo/agency_id;
    Begin_date : /dmo/begin_date;
    End_date : /dmo/end_date;
    
}
