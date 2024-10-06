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
                        'BLLCONTACT' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'contact_1_first_name'],
                        ],
                        'BLLPHONE' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'contact_1_phone']
                        ],
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
                        'status' => 'Active',
                        'tax_manual_override' => 1
                    ],
                    'mapping_array' => [
//                        'ACCTSTATUS' => [
//                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::mapStatusAsActiveInactive',
//                            'function_args' => ['column' => 'status'],
//                        ],
                        'SITENAME' => 'name',
                        'SUPER' => 'contact_2_first_name',
                        'SITEPHONE' => 'contact_2_phone',
                        'SITEFAX' => 'contact_3_phone',
                        'EMAIL' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::cleanEmail',
                            'function_args' => ['column' => 'contact_1_email'],
                        ],
                        'EMAIL2' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::cleanEmail',
                            'function_args' => ['column' => 'contact_2_email'],
                        ],
                        'SITEADDR' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'address_1']
                        ],
                        'SITEADDR2' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'address_2']
                        ],
                        'SITECITY' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'city']
                        ],
                        'SITEZIP' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'zip']
                        ],
                        'COUNTY' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'county']
                        ],
                        'TOWNSHIP' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trim',
                            'function_args' => ['column' => 'township']
                        ],
                        'BILLFIELD' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::stripTags',
                            'function_args' => ['column' => 'billing_note'],
                        ],
                        'DIRMEMO' => [
                            'handler_function' => '\Corals\Modules\Migration\Classes\MigrationHandlers::trimAndStripTags',
                            'function_args' => ['column' => 'job_note'],
                        ],
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
                        'PO_NUM' => 'po_number',
                        'TAXPCNT' => 'tax_rate_1',
                        'TAXPCNT2' => 'tax_rate_2'

                    ],
                    'foreign_columns' => [
                        'CUSTMAST' => [
                            'table' => 'customers',
                            'used_field' => 'number',
                            'mapping_array' => [
                                'id' => 'customer_id',
                                'contact_1_first_name' => 'contact_1_first_name',
                                'contact_1_last_name' => 'contact_1_last_name',
                                'contact_1_phone' => 'contact_1_phone',
                                'contact_1_email' => 'contact_1_email'
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
//                        'ACCTTYPE' => [
//                            'table' => 'code_sets',
//                            'used_field' => 'code',
//                            'mapping_array' => [
//                                'id' => 'market_segment_id'
//                            ]
//                        ],
                        'COCODE' => [
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
                                'CUSTMAST' => 'required',
                                'SUPER' => 'required',
                                'MAPLAT' => 'required',
                                'MAPLONG' => 'required',
                            ],
                            'actions' => [
                                'CUSTMAST' => [
                                    'status' => 'fail'
                                ],
                                'SUPER' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToNA'
                                ],
                                'MAPLAT' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToZero'
                                ],
                                'MAPLONG' => [
                                    'status' => 'fail',
                                    'on_fail' => '\Corals\Modules\Migration\Classes\MigrationHandlers::setToZero'
                                ]
                            ]

                        ]
                    ],
                    'unique_columns' => [
                        'id'
                    ],
                    'pre_create_object' => [
                        '\Corals\Modules\Migration\Classes\MigrationHandlers::preStoreSiteRecord'
                    ]
                ]
            ]
        ]
    ]
];
