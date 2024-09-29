<?php

namespace Corals\Modules\Migration\Providers;

use Corals\Foundation\Providers\BaseInstallModuleServiceProvider;
use Corals\Modules\Migration\database\migrations\MigrationTables;
use Corals\Modules\Migration\database\seeds\MigrationDatabaseSeeder;

class InstallModuleServiceProvider extends BaseInstallModuleServiceProvider
{
    protected $module_public_path = __DIR__ . '/../public';

    protected $migrations = [
        MigrationTables::class,
    ];

    protected function providerBooted()
    {
        $this->createSchema();

        $migrationDatabaseSeeder = new MigrationDatabaseSeeder();

        $migrationDatabaseSeeder->run();
    }
}
