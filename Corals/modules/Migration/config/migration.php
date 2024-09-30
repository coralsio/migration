<?php

return [
    'na_code_id' => 237,
    'seeder' => [
        'customer' => [
            'old_table' => 'jcusf07_customers_dbf',
            'identifier_record' => 'BLLMAST',
            'mapping' => [
                'customers' => [
                    'table_has_auditable' => false,
                    'old_table' => 'jcusf07_customers_dbf',
                    'new_table' => 'customers',
                    'mapping_array' => [
                        'BLLMAST' => 'number',
                        'BLLNAME' => 'company_name',
                        'BLLADDR' => 'address_1',
                        'BLLADDR2' => 'address_2',
                        'BLLCITY' => 'city',
                        'BLLCONTACT' => 'contact_1_first_name',
                        'BLLPHONE' => 'contact_1_phone',
                        'BLLEMAIL1' => 'contact_1_email',
                        'BLLFAX' => 'contact_2_phone',
                        'BLLEMAIL2' => 'contact_2_email',
                        'BLLCRLMT' => [
                            'credit_limit',
                            'credit_amount'
                        ]
                    ],
                    'foreign_columns' => [
                        'BLLSTATE' => [
                            'table' => 'code_sets',
                            'used_field' => 'code',
                            'mapping_array' => [
                                'id' => [
                                    'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNaCodeId',
                                    'function_args' => ['column' => 'state_id'],
                                ]
                            ]
                        ],
                        'BLLCOCODE' => [
                            'table' => 'divisions',
                            'used_field' => 'division_code',
                            'mapping_array' => [
                                'id' => 'division_id'
                            ]
                        ]
                    ],
                    'validations' => [
                        'old_record_validations' => [
                            'rules' => [
                                'BLLCONTACT' => 'required',
                                'BLLMAST' => 'required',
                                'BLLPHONE' => 'required',
                                'BLLEMAIL1' => 'required|email',
                                'BLLNAME' => 'required'
                            ],
                            'actions' => [
                                'BLLMAST' => ['status' => 'fail'],
                                'BLLNAME' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNA'
                                ],
                                'BLLCONTACT' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNA'
                                ],
                                'BLLPHONE' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToPhoneNumberPlaceholder'
                                ],
                                'BLLEMAIL1' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNoEmail'
                                ],
                            ]
                        ]
                    ],
                    'unique_columns' => [
                        'number'
                    ],
                    'pre_create_object' => [
                        '\Corals\Modules\Migration\Classes\MigrationHandlers::preStoreCustomerRecord'
                    ],
                    'appended_columns' => [
                        'invoice_settings' => 'Standard',
                        'default_surcharge_rate' => 0,
                        'customer_bill_through_date_selection' => 'Earliest'
                    ]
                ],
            ]
        ],
        'site' => [
            'old_table' => 'jcusf01_sites_dbf',
            'identifier_record' => 'CUSTNUM',
            'mapping' => [
                'sites' => [
                    'table_has_auditable' => false,
                    'old_table' => 'jcusf01_sites_dbf',
                    'new_table' => 'sites',
                    'appended_columns' => [
                        'contact_1_first_name' => 'NA',
                        'contact_1_last_name' => 'NA',
                        'contact_1_email' => 'noemail@email.com',
                        'contact_1_phone' => '000-000-0000',
                    ],
                    'mapping_array' => [
                        'ACCTSTATUS' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::mapStatusAsActiveInactive',
                            'function_args' => ['column' => 'status'],
                        ],
                        'SITENAME' => 'name',
                        'SUPER' => 'contact_2_first_name',
                        'SITEPHONE' => 'contact_2_email',
                        'EMAIL' => 'contact_3_first_name',
                        'SITEFAX' => 'contact_3_phone',
                        'EMAIL2' => 'contact_3_email',
                        'SITEADDR' => 'address_1',
                        'SITEADDR2' => 'address_2',
                        'SITECITY' => 'city',
                        'SITEZIP' => 'zip',
                        'COUNTY' => 'county',
                        'TOWNSHIP' => 'township',
                        'CCARDTYPE' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::mapCreditCardType',
                            'function_args' => ['column' => 'card_type'],
                        ],
                        'BILLFIELD' => 'billing_note',
                        'DIRMEMO' => 'job_note',
                        'MAPLAT' => 'latitude',
                        'MAPLONG' => 'longitude',
                        'LLCCBILL' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::mapPaymentMethod',
                            'function_args' => ['column' => 'payment_method'],
                        ],
                        'STATEPRNT' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::mapToBoolean',
                            'function_args' => ['column' => 'invoice_method_statement'],
                        ],
//                        'TERMS' => 'billing_terms',

                        'TAXPCNT' => 'tax_rate_1',
                        'TAXPCNT2' => 'tax_rate_2'

                    ],
                    'foreign_columns' => [
                        'CUSTMAST' => [
                            'table' => 'customers',
                            'used_field' => 'number',
                            'mapping_array' => [
                                'id' => 'customer_id'
                            ]
                        ],
                        'SITESTATE' => [
                            'table' => 'code_sets',
                            'used_field' => 'code',
                            'mapping_array' => [
                                'id' => [
                                    'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNaCodeId',
                                    'function_args' => ['column' => 'state_id'],
                                ]
                            ]
                        ],
                        'ACCTTYPE' => [
                            'table' => 'code_sets',
                            'used_field' => 'code',
                            'mapping_array' => [
                                'id' => 'market_segment_id'
                            ]
                        ],
                        'COCODE' => [
                            'table' => 'divisions',
                            'used_field' => 'division_code',
                            'mapping_array' => [
                                'id' => 'division_id'
                            ]
                        ],
                        'SALECREDIT' => [
                            'table' => 'code_sets',
                            'used_field' => 'code',
                            'mapping_array' => [
                                'id' => 'billing_term_id'
                            ]
                        ],
                    ],
//                    'unique_columns' => [
//                        'id'
//                    ],
                ]
            ]
        ]
    ]
];
