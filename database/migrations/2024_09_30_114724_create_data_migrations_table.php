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
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('data_migrations', function (Blueprint $table) {
            $table->increments('id');
            $table->string('config_path', 70)->index();
            $table->string('table_name', 70)->index();
            $table->string('table_reference', 70)->index();
            $table->longText('payload');
            $table->boolean('processed')->default(true)->index();
            $table->longText('message');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('data_migrations');
    }
};