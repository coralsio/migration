<?php

namespace Corals\Modules\Migration\Console\Commands;

use Corals\Modules\Migration\Classes\OldDatabaseSeeder;
use Illuminate\Console\Command;

class SyncOldDB extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:sync {config} {module?} {section?} {--start-date=} {--end-date=} {--first-time-seeding}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Used to sync data from old database';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->setDBTimeZone(config('app.timezone'));

        try {
            $firstTimeSeeding = $this->option('first-time-seeding');
            $configName = $this->argument('config');
            $startDate = $this->option('start-date');
            $endDate = $this->option('end-date');
            $module = $this->argument('module');
            $section = $this->argument('section');


            $moduleConfig = config("$configName.seeder", []);

            if ($module) {
                if (isset($moduleConfig[$module])) {
                    $modules = [$module => $moduleConfig[$module]];
                } else {
                    throw new \Exception($module . ' module not found!!');
                }
            } else {
                $modules = $moduleConfig;
            }

            foreach ($modules as $module => $configArray) {
                $progressBar = $this->output->createProgressBar(count($configArray['mapping']));
                $progressBar->setFormat('debug');

                $start = microtime(true);

                $config_path = "$configName.seeder." . $module;

                $oldDBSeeder = new OldDatabaseSeeder($config_path, $configArray, $startDate, $endDate, $this,
                    $this->output, $section, $firstTimeSeeding);

                $this->line("\nStart with '$module' ...");

                $oldDBSeeder->migrationLog("Start with '$module' ...");

                $oldDBSeeder->seedFromOldDB();

                $time_elapsed_secs = microtime(true) - $start;

                $this->line("Execution Time: $time_elapsed_secs");

                $oldDBSeeder->migrationLog("Execution Time: $time_elapsed_secs");

                $progressBar->advance();

                $progressBar->finish();
            }
        } catch (\Exception $exception) {
            log_exception($exception, 'Seeding', 'seed');
            $this->error($exception->getMessage());
        }
    }

    /**
     * @param $timeZone
     */
    protected function setDBTimeZone($timeZone): void
    {
        //check if is valid timezone
        if (array_search($timeZone, timezone_identifiers_list()) !== false) {
            date_default_timezone_set($timeZone);
            \DB::statement('SET time_zone = "' . date('P', time()) . '";');
        }
    }
}
