<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * @var string
     */
    protected $connection = 'mysql_migration_new';

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::table('customers')->where('number', 'NA')->delete();
        DB::table('code_sets')->where('code', 'NA')
            ->where('parent_id', 1)
            ->delete();

        DB::table('customers')->insert([
            'number' => 'NA',
            'customer_number' => 'NA',
            'company_name' => 'NA',
            'contact_1_first_name' => 'NA',
            'contact_1_last_name' => 'NA',
            'contact_1_phone' => '000-000-0000',
            'contact_1_email' => 'noemail@email.com',
            'default_bill_type' => '28 Day Fixed',
            'tax_manual_override' => 1,
            'customer_market_segment_id' => 166,
//            'site_bill_through_date_selection' => 'Earliest',
            'scheduling_settings' => 'Arrears'
        ]);

        DB::table('code_sets')->insert([
            'code' => 'NA',
            'value' => 'NA',
            'description' => 'NA',
            'parent_id' => 1,
        ]);

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('customers')->where('number', 'NA')->delete();

        DB::table('code_sets')->where('code', 'NA')
            ->where('parent_id', 1)
            ->delete();

    }
};
