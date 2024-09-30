<?php

namespace Corals\Modules\Migration;

use Corals\Foundation\Providers\BasePackageServiceProvider;
use Corals\Modules\Migration\Console\Commands\SyncOldDB;
use Corals\Modules\Migration\Facades\Migration;
use Corals\Modules\Migration\Providers\MigrationAuthServiceProvider;
use Corals\Settings\Facades\Modules;
use Illuminate\Foundation\AliasLoader;

class MigrationServiceProvider extends BasePackageServiceProvider
{
    protected $defer = true;

    /**
     * @var string
     */
    protected $packageCode = 'corals-migration';

    /**
     * Bootstrap the application events.
     *
     * @return void
     */

    public function bootPackage()
    {
        $this->commands(SyncOldDB::class);
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function registerPackage()
    {

        $this->mergeConfigFrom(__DIR__ . '/config/migration.php', 'migration');

        $this->app->register(MigrationAuthServiceProvider::class);

        $this->app->booted(function () {
            $loader = AliasLoader::getInstance();
            $loader->alias('Migration', Migration::class);
        });
    }

    /**
     * @return mixed|void
     */
    public function registerModulesPackages()
    {
        Modules::addModulesPackages('corals/migration');
    }
}
