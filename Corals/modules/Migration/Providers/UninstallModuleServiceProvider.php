<?php

namespace Corals\Modules\Migration\Providers;

use Corals\Foundation\Providers\BaseUninstallModuleServiceProvider;
use Corals\Modules\Migration\database\migrations\MigrationTables;
use Corals\Modules\Migration\database\seeds\MigrationDatabaseSeeder;

class UninstallModuleServiceProvider extends BaseUninstallModuleServiceProvider
{
    protected $migrations = [
        MigrationTables::class,
    ];

    protected function providerBooted()
    {
        $this->dropSchema();

        $migrationDatabaseSeeder = new MigrationDatabaseSeeder();

        $migrationDatabaseSeeder->rollback();
    }
}
