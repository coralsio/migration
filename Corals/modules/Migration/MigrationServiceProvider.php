<?php

namespace Corals\Modules\Migration;

use Corals\Modules\Migration\Console\Commands\SyncOldDB;
use Corals\Modules\Migration\Facades\Migration;
use Corals\Modules\Migration\Providers\MigrationAuthServiceProvider;
use Illuminate\Foundation\AliasLoader;
use Illuminate\Support\ServiceProvider;

class MigrationServiceProvider extends ServiceProvider
{
    protected $defer = true;

    /**
     * Bootstrap the application events.
     *
     * @return void
     */

    public function boot()
    {
        $this->commands(SyncOldDB::class);
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        $this->mergeConfigFrom(__DIR__ . '/config/migration.php', 'migration');

        $this->app->register(MigrationAuthServiceProvider::class);

        $this->app->booted(function () {
            $loader = AliasLoader::getInstance();
            $loader->alias('Migration', Migration::class);
        });
    }
}
