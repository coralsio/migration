set FOREIGN_key_checks = 0;
truncate table pf_new.divisions;
INSERT INTO pf_new.divisions (id,
                              division_code,
                              name,
                              address_2,
                              address_1,
                              city,
                              state_id,
                              zip,
                              phone,
                              fax,
                              yard_name,
                              yard_latitude,
                              yard_longitude,
                              alternate_address,
                              email,
                              alternate_remittance_address,
                              default_reminder_interval,
                              notification_preference_email,
                              notification_preference_sms,
                              notification_preference_mailing_label,
                              notification_preference_postcard,
                              invoice_setting_print_logo,
                              invoice_setting_print_email,
                              invoice_setting_print_mail,
                              invoice_setting_print_alternate_address,
                              invoice_setting_print_balance,
                              invoice_setting_print_mini_statement,
                              invoice_setting_message_1,
                              invoice_setting_message_2,
                              invoice_setting_message_3,
                              invoice_setting_message_4,
                              invoice_setting_detach_tear_off,
                              invoice_setting_detach_credit_card_option,
                              invoice_setting_billing_proration_standard,
                              invoice_setting_invoice_type,
                              invoice_setting_iaf_days_to_advance,
                              invoice_setting_iaf_fee_schedule,
                              invoice_setting_aging_offset,
                              invoice_setting_print_wo_number,
                              invoice_setting_print_asset_serial_numbers,
                              invoice_setting_print_dates_on_line_charges,
                              invoice_setting_print_unit_quantity,
                              invoice_setting_print_service_interval,
                              billing_setting_surcharge_id,
                              billing_setting_surcharge_rate,
                              billing_setting_print_receipt_on_invoice,
                              billing_setting_invoice_method_statement,
                              billing_setting_invoice_method_print,
                              billing_setting_invoice_method_email,
                              billing_setting_terms,
                              invoice_settings,
                              tax_settings,
                              tax_rate_2,
                              tax_rate_3,
                              work_order_setting_print_client_name,
                              work_order_setting_print_logo,
                              work_order_setting_operational_message,
                              work_order_setting_default_service_type_id,
                              work_order_setting_default_rate_code_id,
                              work_order_setting_print_cod_value,
                              work_order_setting_print_equipment_info,
                              work_order_setting_print_equipment_images,
                              work_order_setting_print_item_details,
                              work_order_setting_print_item_details_with_dollar,
                              work_order_setting_print_statement,
                              work_order_setting_print_billing_note,
                              work_order_setting_print_service_stops_and_units,
                              work_order_setting_print_serial_numbers,
                              work_order_setting_print_rental_units,
                              work_order_setting_print_site_map,
                              min_late_charge,
                              late_charge,
                              tax_rate_1,
                              division_market_segment_id
)
SELECT ROW_NUMBER()                                                              OVER(ORDER BY a.cocode ASC) AS ID
	, a.cocode as division_code
     , company                                                                as name
     , RTRIM(coaddress2)                                                      as address_2
     , RTRIM(coaddress)                                                       as address_1
     , cocity                                                                 as city
     , (select MAX(id) from pf_new.code_sets where code = costate and parent_id = 1) as state_id
     , cozip                                                                  as zip
     , cophone                                                                as phone
     , cofax                                                                  as fax
     , yardname                                                               as yard_name
     , case when yardlat = '' then '0.00000000' else yardlat end              as yard_latitude
     , case when yardlong = '' then '0.00000000' else yardlong end          as yard_longitude
     , 0                                                                      as alternate_address
     , null as email
     , null as alternate_remittance_address
     , COALESCE(NULLIF((Select CASE upper(refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7018'),''),0) as default_reminder_interval
     , 1 as notification_preference_email
     , 1 as notification_preference_sms
     , 1 as notification_preference_mailing_label
     , 0 as notification_preference_postcard
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7018' limit 1),''),0) as invoice_setting_print_logo
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7018' limit 1),''),0) as invoice_setting_print_email
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7018' limit 1),''),0) as invoice_setting_print_mail
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1122' limit 1),''),0) as invoice_setting_print_alternate_address
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '3003' limit 1),''),0) as invoice_setting_print_balance
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '3004' limit 1 ),''),0) as invoice_setting_print_mini_statement
     , ( Select refdesc from jref0r2 where refcode = '7013' limit 1 ) as invoice_setting_message_1
     , ( Select refdesc from jref0r2 where refcode = '7237'limit 1 ) as invoice_setting_message_2
     , ( Select refdesc from jref0r2 where refcode = '7207' limit 1) as invoice_setting_message_3
     , ( Select refdesc from jref0r2 where refcode = '1138' limit 1) as invoice_setting_message_4
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1147' limit 1),''),0) as invoice_setting_detach_tear_off
     , COALESCE(NULLIF(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1109' limit 1),''),0) as invoice_setting_detach_credit_card_option
     , COALESCE(( Select CASE upper (refdesc) when '0' then 'Earliest' when '1' then 'Latest' else refdesc END from jref0r2 where refcode = '1143' limit 1),'None') as invoice_setting_billing_proration_standard
     , 'Billable' as invoice_setting_invoice_type
     , COALESCE (( Select refdesc from jref0r2 where refcode = '1101' limit 1),'14') as invoice_setting_iaf_days_to_advance
     , 'Daily' as invoice_setting_iaf_fee_schedule
     , COALESCE (( Select refdesc from jref0r2 where refcode = '1100' ),0) as invoice_setting_aging_offset
     , COALESCE (( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1111' limit 1),0) as invoice_setting_print_wo_number
     , COALESCE (( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1018' limit 1),0) as invoice_setting_print_asset_serial_numbers
     , COALESCE (( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1020' limit 1),0) as invoice_setting_print_dates_on_line_charges
     , COALESCE (( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1141' limit 1),0) as invoice_setting_print_unit_quantity
     , COALESCE (( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1010' limit 1),0)as invoice_setting_print_service_interval
     , null as billing_setting_surcharge_id
     , 0  as billing_setting_surcharge_rate
     , 1 as billing_setting_print_receipt_on_invoice
     , 1 as billing_setting_invoice_method_statement
     , 1 as billing_setting_invoice_method_print
     , 1 as billing_setting_invoice_method_email
     , COALESCE(( Select refdesc from jref0r2 where refcode = '7116' limit 1),'DOR') as billing_setting_terms
     , 'Standard' as invoice_settings
     , 1 as tax_settings
     , COALESCE(( Select refdesc from jref0r2 where refcode = '7114' limit 1 ),0) as tax_rate_2
     , COALESCE(( Select refdesc from jref0r2 where refcode = '7115' limit 1 ),0) as tax_rate_3
     ,  COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '2001' limit 1),0) as work_order_setting_print_client_name
     ,  COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '2001' limit 1),0) as work_order_setting_print_logo
     , ( Select refdesc from jref0r2 where refcode = '7023' limit 1) as work_order_setting_operational_message
     , ( Select cs.id from jref0r2 j2 inner join pf_new.code_sets cs on j2.refdesc = cs.code
    where refcode = '7003' and cs.parent_id = 111 limit 1) as work_order_setting_default_service_type_id
     , ( Select cs.id from jref0r2 j2 inner join pf_new.code_sets cs on j2.refdesc = cs.code
    where refcode = '1116' and cs.parent_id = 106 limit 1) as work_order_setting_default_rate_code_id
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '1119' limit 1),0)  as work_order_setting_print_cod_value
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '2002' limit 1),0)  as work_order_setting_print_equipment_info
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '2011' limit 1),0)  as work_order_setting_print_equipment_images
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7250' limit 1),0)  as work_order_setting_print_item_details
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7250' limit 1),0)  as work_order_setting_print_item_details_with_dollar
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7222' limit 1),0)  as work_order_setting_print_statement
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7223' limit 1),0)  as work_order_setting_print_billing_note
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7019' limit 1),0)  as work_order_setting_print_service_stops_and_units
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7020' limit 1),0)  as work_order_setting_print_serial_numbers
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '7019' limit 1),0)  as work_order_setting_print_rental_units
     , COALESCE(( Select CASE upper (refdesc) when 'Y' then 1 when 'TRUE' then 1 when 'N' then 0 when 'FALSE' then 0 else refdesc END from jref0r2 where refcode = '2013' limit 1),0)  as work_order_setting_print_site_map
     , b.latedol as min_late_charge
     , b.lateper as late_charge
     , b.taxrate as tax_rate_1
     , (Select id from pf_new.code_sets where parent_id = 101 limit 1) as division_market_segment_id
FROM jreff01 a
    left outer join jreff03 b on a.cocode = b.cocode;

update pf_new.divisions set billing_setting_terms = 'NET30';
-- update pf_new.divisions set invoice_setting_message_2 = StripHTML2(invoice_setting_message_2);
update pf_new.divisions set invoice_setting_iaf_days_to_advance = '14' where invoice_setting_iaf_days_to_advance = '0';

update pf_new.divisions set is_default = 1 limit 1;
