<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * @var string
     */
    protected $connection = 'mysql_migration_new';

    /**
     * @var string[][]
     */
    protected $tempColumns = [
        'template_work_orders' => [
            'autoid',
            'custnum'
        ],
        'work_orders' => [
            'custnum',
            'autoid',
            'invno',
            'mediajoinkey'
        ],
        'equipments' => [
            'mediajoinkey'
        ],
        'pricing_templates' => [
            'custnum',
            'serial'
        ],
        'work_order_services' => [
            'custnum'
        ],
        'notes' => [
            'seqid'
        ]
    ];

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        foreach ($this->tempColumns as $tableName => $tempColumns) {
            Schema::table($tableName, function (Blueprint $table) use ($tableName, $tempColumns) {
                foreach ($tempColumns as $tempColumn) {
                    if (Schema::hasColumn($tableName, $tempColumn)) {
                        continue;
                    }

                    $table->string($tempColumn)->nullable();
                }
            });
        }

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach ($this->tempColumns as $tableName => $tempColumns) {
            Schema::table($tableName, function (Blueprint $table) use ($tableName, $tempColumns) {
                foreach ($tempColumns as $tempColumn) {
                    if (Schema::hasColumn($tableName, $tempColumn)) {
                        $table->dropColumn($tempColumn);
                    }
                }
            });
        }
    }
};
