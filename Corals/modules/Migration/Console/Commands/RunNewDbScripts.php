<?php

namespace Corals\Modules\Migration\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class RunNewDbScripts extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'run-new-db {folder : The folder containing SQL scripts to run sequentially} {new_db} {old_db}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Run all SQL scripts in the given folder in sequence';

    /**
     * Execute the console command.
     *
     * @return int
     */

    protected $newDbConnection;
    protected $oldDbConnection;

    public function __construct()
    {
        $this->newDbConnection = DB::connection('mysql_migration_new');
        $this->oldDbConnection = DB::connection('mysql_migration_old');
        parent::__construct();
    }

    /**
     * @throws \Throwable
     */
    public function handle()
    {
        $folder = $this->argument('folder');
        $newDB = $this->argument('new_db');
        $oldDB = $this->argument('old_db');

        if (!File::exists($folder) || !File::isDirectory($folder)) {
            $this->error("The folder {$folder} does not exist or is not a directory.");
            return Command::FAILURE;
        }

        $files = File::files($folder);

        $sqlFiles = collect($files)
            ->filter(function ($file) {
                return $file->getExtension() === 'sql';
            });

        if ($sqlFiles->isEmpty()) {
            $this->error("No SQL files found in the folder {$folder}.");
            return Command::FAILURE;
        }


        $this->truncateAllNewDbTables();

        foreach ($sqlFiles as $file) {
            $this->info("{$file->getFilename()} is executing");
            try {
                $sql = File::get($file->getPathname());
                $sql = str_replace('{db_new}', $newDB, $sql);
                $sql = str_replace('{db_old}', $oldDB, $sql);

                $this->newDbConnection->unprepared($sql);
                $this->info("Executed successfully: {$file->getFilename()}");
            } catch (\Exception $e) {
                report($e);
                $this->error("Error executing file: {$file->getFilename()}");
                $this->error("Error message: " . strtok($e->getMessage(), "\n"));
                return Command::FAILURE;
            }
        }
        $this->info('All scripts executed successfully!');


        return Command::SUCCESS;
    }

    public function truncateAllNewDbTables()
    {
        $this->info("Truncating all new DB tables...");

        $this->newDbConnection->statement('SET FOREIGN_KEY_CHECKS = 0');

        $tables = $this->newDbConnection->table('information_schema.tables')
            ->where('TABLE_SCHEMA', $this->newDbConnection->getDatabaseName())
            ->pluck('TABLE_NAME');

        $progressBar = $this->output->createProgressBar($tables->count());

        $tables->each(function ($table) use ($progressBar) {
            $this->newDbConnection->table($table)->truncate();
            $progressBar->advance();
        });


        $this->newDbConnection->statement('SET FOREIGN_KEY_CHECKS = 1');
        $progressBar->finish();
    }
}
