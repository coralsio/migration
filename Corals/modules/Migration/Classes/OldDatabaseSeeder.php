<?php

namespace Corals\Modules\Migration\Classes;

use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OldDatabaseSeeder
{

    protected $config;
    protected $configPath = null;
    protected $configArray = null;
    protected $startDate = null;
    protected $endDate = null;
    protected $console = null;
    protected $currentConfigPathKey = null;
    protected $output = null;
    protected $firstTimeSeeding = false;
    protected $section;
    protected $bulkDBLogInsert = [];
    protected $referenceTables = [];
    protected $referenceColumns = [];

    /**
     * OldDatabaseSeeder constructor.
     * @param $configPath
     * @param $configArray
     * @param $startDate
     * @param $endDate
     * @param $console
     * @param $output
     * @param $section
     * @param $firstTimeSeeding
     */
    public function __construct(
        $configPath,
        $configArray,
        $startDate,
        $endDate,
        $console,
        $output,
        $section,
        $firstTimeSeeding
    )
    {
        $this->configPath = $configPath;
        $this->configArray = $configArray;
        $this->firstTimeSeeding = $firstTimeSeeding;

        $this->startDate = $startDate;
        $this->endDate = $endDate;
        $this->console = $console;
        $this->output = $output;
        $this->section = $section;

        DB::statement('SET unique_checks=0;');
        DB::statement('SET foreign_key_checks=0;');

        $this->migrationLog('OldDatabaseSeeder@__construct::START');
        $this->migrationLog('$configPath::' . $configPath);
        $this->migrationLog('$startDate::' . $startDate);
    }

    /**
     * seedFromOldDB
     */
    public function seedFromOldDB()
    {
        DB::setDefaultConnection('mysql_migration_new');

        $this->migrationLog('OldDatabaseSeeder@seedFromOldDB::START');

        $oldTable = $this->configArray['old_table'];

        $orderByColumn = $this->configArray['orderBy_column'] ?? null;

        $orderBy_direction = $this->configArray['orderBy_direction'] ?? 'ASC';

        $creationDateField = $this->configArray['creation_date_field'] ?? null;

        $oldTableIdentifierColumn = $this->configArray['identifier_record'];

        $sections = $this->configArray['mapping'];

        //Handling orderBy column for using chunk
        if (!$orderByColumn) {
            $oldColumnsNames = DB::connection('mysql_migration_old')->getSchemaBuilder()->getColumnListing($oldTable);
            $orderByColumn = $oldColumnsNames[0];
        }


        if ($this->section) {
            if (isset($this->configArray['mapping'][$this->section])) {
                $sections = [$this->section => $this->configArray['mapping'][$this->section]];
            } else {
                throw new \Exception($this->section . ' section not found!!');
            }
        }

        foreach ($sections as $key => $mapping) {
            if (\Arr::get($mapping, 'disabled', false)) {
                $this->migrationLog("$key Mapping disabled. skipped!", true);
                continue;
            }

            $this->currentConfigPathKey = $key;

            $this->migrationLog("Process $key Mapping", true);

            $conditions = $mapping['conditions'] ?? [];

            $queriesConfig = $mapping['queries_config'] ?? [];

            $foreignColumns = $mapping['foreign_columns'] ?? [];

            $this->getReferenceTables($foreignColumns);


            $this->migrationLog('connect to old db and start fetching records');

            $queryBuilder = DB::connection('mysql_migration_old')
                ->table($oldTable)
                ->orderBy($orderByColumn, $orderBy_direction);

            //apply joins with selects
            if ($queriesConfig) {
                $queryBuilder = MigrationHandlers::handleExtraQueries($queryBuilder, $queriesConfig);
            }

            if ($this->startDate && $creationDateField && $creationDateField !== '') {
                $queryBuilder->whereDate($creationDateField, '>=', $this->startDate);
            }

            if ($this->endDate && $creationDateField && $creationDateField !== '') {
                $queryBuilder->whereDate($creationDateField, '<=', $this->endDate);
            }

            if (!empty($conditions)) {
                $queryBuilder = MigrationHandlers::applySubQueries($queryBuilder, $conditions);
            }

            $handledRecords = 0;

            $queryRecordsCount = $this->getRecordsCount($queryBuilder);

            $this->migrationLog("[{$key}] Records to migrate: $queryRecordsCount records", true);

            $progressBar = $this->output->createProgressBar($queryRecordsCount);

            $progressBar->setFormat('debug');
            $progressBar->setProgress(0);

            $queryBuilder->chunk(1000, function ($oldRecords)
            use (
                $oldTableIdentifierColumn,
                $orderByColumn,
                &$handledRecords,
                $oldTable,
                $key,
                $mapping,
                &$progressBar
            ) {
                $startTime = microtime(true);
                $currentChunk = 0;
                foreach ($oldRecords as $oldRecord) {
                    $this->migrationLog("[{$key}] Seeding Record with $oldTableIdentifierColumn : " . $oldRecord->{$oldTableIdentifierColumn});

                    try {
                        $oldRecordValidations = $mapping['validations']['old_record_validations'] ?? [];

                        if (!empty($oldRecordValidations)) {
                            $this->migrationLog("Validate old record: " . $oldRecord->{$oldTableIdentifierColumn});
                            if (!$this->validate($oldRecord, $oldRecordValidations)) {
                                continue;
                            }
                        }

                        $newTableBuilder = DB::table($mapping['new_table']);

                        list($newObjectId, $newRecord) = $this->createNewObject($newTableBuilder, $oldRecord, $mapping);

                        if (empty($newObjectId)) {
                            continue;
                        }

                        //if the old table is mapped into two new tables
                        $this->handleRelatedTables($mapping, $oldRecord, $newObjectId, $oldTableIdentifierColumn,
                            $oldTable);

                        //Handling many-many relations

                        $postCreateObject = $mapping['post_create_object'] ?? [];

                        if (!empty($postCreateObject)) {
                            if (!is_array($postCreateObject)) {
                                $postCreateObject = [$postCreateObject];
                            }
                            foreach ($postCreateObject as $handler) {
                                $handlerFunction = $handler['handler_function'];
                                $handlerArguments = $handler['function_args'] ?? [];
                                $handlerFunction($oldRecord, $newRecord, $newObjectId, $handlerArguments);
                            }
                        }
                        //insert into data migrations table
                        $this->insertIntoDataMigrationTable($oldRecord, $oldTableIdentifierColumn, $oldTable,
                            'success');

                        $this->migrationLog("_________________________________________________________Successfully Handled [$key] Records: $handledRecords");
                    } catch (\Exception $exception) {
//                        report($exception);
                        $this->migrationLog($exception->getMessage(), false, 'error');

                        $this->insertIntoDataMigrationTable($oldRecord, $oldTableIdentifierColumn, $oldTable,
                            $exception->getMessage(), false);
                    } finally {
                        $currentChunk++;
                        $handledRecords++;
                    }
                }

                $this->migrationLog("[{$key}] Seeding [{$handledRecords}] DURATION:   " . \Corals\Modules\Migration\Facades\Migration::getMicroTimeDuration($startTime,
                        microtime(true), true));

                $progressBar->advance($currentChunk);

                flush();
            });
            $this->console->line('');


            if (count($this->bulkDBLogInsert)) {
                DB::table('data_migrations')->insert($this->bulkDBLogInsert);
                $this->bulkDBLogInsert = [];
            }
        }

        $this->migrationLog('OldDatabaseSeeder@seedFromOldDB::END');
    }

    private function handleRelatedTables($mapping, $oldRecord, $newObjectId, $oldTableIdentifierColumn, $oldTable)
    {
        $relatedTables = $mapping['related_table'] ?? [];

        if (!empty($relatedTables)) {
            if (isset($relatedTables['config'])) {
                $relatedTables = [$relatedTables];
            }

            foreach ($relatedTables as $relatedTableKey => $table) {
                try {
                    $relatedTableConfig = $table['config'];

                    if (isset($relatedTableConfig['foreign_columns'])) {
                        $this->getReferenceTables($relatedTableConfig['foreign_columns']);
                    }

                    $columnName = $table['column_name'];
                    $relatedTableConfig['appended_columns'][$columnName] = $newObjectId;
                    $relatedTableBuilder = DB::table($relatedTableConfig['new_table']);

                    $oldRecordValidations = $relatedTableConfig['validations']['old_record_validations'] ?? [];
                    if (!empty($oldRecordValidations)) {
                        if (!$this->validate($oldRecord, $oldRecordValidations)) {
                            continue;
                        }
                    }
                    list($newRecordID, $newRecord) = $this->createNewObject($relatedTableBuilder, $oldRecord,
                        $relatedTableConfig);

                    if (isset($relatedTableConfig['related_table'])) {
                        $this->handleRelatedTables($relatedTableConfig, $oldRecord, $newRecordID,
                            $oldTableIdentifierColumn, $oldTable);
                    }
                } catch (\Exception $exception) {
//                    report($exception);
                    $this->migrationLog($exception->getMessage(), false, 'error');
                    $this->insertIntoDataMigrationTable($oldRecord, $oldTableIdentifierColumn, $oldTable,
                        'Related Table::' . $relatedTableKey . '::' . $exception->getMessage(), false);
                }
            }
        }
    }

    private function createNewObject($newTableBuilder, $oldRecord, $configArray)
    {
        $newRecord = [];
        $mappingArray = $configArray['mapping_array'];
        $foreignColumns = $configArray['foreign_columns'] ?? [];
        $appendedColumns = $configArray['appended_columns'] ?? [];
        $uniqueColumns = $configArray['unique_columns'] ?? [];
        $newRecordValidations = $configArray['validations']['new_record_validations'] ?? [];
        $newObjectId = null;

        $this->handleForeignColumns($oldRecord, $foreignColumns, $newRecord);

        foreach ($mappingArray as $oldColumn => $newColumns) {
            if (is_array($newColumns) && isset($newColumns['handler_function'])) {
                $newColumns = [$newColumns];
            }
            if (!is_array($newColumns)) {
                $newColumns = [$newColumns];
            }

            foreach ($newColumns as $newColumn) {
                $newValue = null;

                if (is_array($newColumn) && isset($newColumn['handler_function'])) {
                    $handlerFunction = $newColumn['handler_function'] ?? '';
                    if (!empty($handlerFunction)) {
                        $functionArguments = $newColumn['function_args'];
                        $new_column = $functionArguments['column'];

                        $preHandlerFunction = $newColumn['pre_handler_function'] ?? '';

                        if (!empty($preHandlerFunction)) {
                            $preFunctionArgs = $newColumn['pre_function_args'] ?? [];
                            $newValue = $preHandlerFunction($oldRecord, $oldColumn, $newRecord, $new_column, $newValue,
                                $preFunctionArgs);
                        }

                        $newRecord["$new_column"] = $this->trimValues($handlerFunction($oldRecord, $oldColumn,
                            $newRecord, $new_column, $newValue, $functionArguments));
                    }
                } elseif (!is_array($newColumn) && !isset($foreignColumns[$oldColumn])) {
                    $newRecord["$newColumn"] = $this->trimValues($oldRecord->{$oldColumn});
                } elseif (isset($foreignColumns[$oldColumn])) {
                    $newRecord["$newColumn"] = $this->trimValues($newValue);
                } else {
                    throw new \Exception("Invalid Config For " . $this->configPath);
                }
            }
        }
        //loop through json columns and encode them into json format
        foreach ($configArray['json_columns'] ?? [] as $json_column) {
            if (isset($newRecord["$json_column"])) {
                $newRecord["$json_column"] = json_encode($newRecord["$json_column"]);
            }
        }


        $newRecord = array_merge($newRecord, $appendedColumns);

        $preCreateObjectHandlers = $configArray['pre_create_object'] ?? '';

        if (!is_array($preCreateObjectHandlers)) {
            $preCreateObjectHandlers = [$preCreateObjectHandlers];
        }

        foreach ($preCreateObjectHandlers as $handler) {
            if (!empty($handler)) {
                $handler($oldRecord, $newRecord);
            }
        }


        //validate new record before inserting it
        if (!empty($newRecordValidations)) {
            $this->migrationLog("Validate new record");

            if (!$this->validate($newRecord, $newRecordValidations)) {
                return false;
            }
        }


        if (empty($uniqueColumns) && !$this->firstTimeSeeding) {
            $uniqueColumns = ['migration_reference'];
        }

        $this->checkNewRecordBeforeInsert($newRecord, $configArray);

        if (!empty($uniqueColumns)) {
            $uniqueColumnsValues = array_intersect_key($newRecord, array_flip($uniqueColumns));

            $newObjectId = $this->updateOrInsertGetId($newTableBuilder, $uniqueColumnsValues, $newRecord);
        } else {
            $newObjectId = $newTableBuilder->insertGetId($newRecord);
        }


        if (array_key_exists($configArray['new_table'], $this->referenceColumns)) {
            $newTable = $configArray['new_table'];

            $foreignConfig = array_filter($foreignColumns, function ($value) use ($newTable) {
                if (\Arr::get($value, 'table') == $newTable) {
                    return $value;
                }
            });

            foreach ($foreignConfig as $config) {
                $keys = array_keys($config['mapping_array']);
                foreach ($keys as $key) {
                    $this->referenceTables[$newTable][$key][$newRecord[$this->referenceColumns[$newTable]]] = $newObjectId;
                }
            }
        }

        return [$newObjectId, $newRecord];
    }

    private function getReferenceTables($foreignColumns)
    {
        foreach ($foreignColumns as $foreignColumn => $attributes) {
            $this->migrationLog('getReferenceTables - foreignColumn:[ ' . $foreignColumn . ' ]');

            $referenceTableName = $attributes['table'];
            $usedField = $attributes['used_field'];

            if (!isset($this->referenceTables[$referenceTableName])) {
                //TODO: maybe two old columns use the same table but different foreign field? like name & code?
                //we can modify it to store it without pluck but handling it in field_id_mapping

                if ($mappingArray = $attributes['mapping_array'] ?? []) {
                    $keys = array_keys($mappingArray);
                } else {
                    $keys = ['id'];
                }

                foreach ($keys as $key) {
                    $this->referenceTables[$referenceTableName][$key] = DB::table($referenceTableName)
                        ->select(DB::raw('trim(lower(' . $usedField . ')) as used_field'), $key)
                        ->whereNotNull($usedField)
                        ->pluck($key, 'used_field')->toArray();
                    $this->referenceColumns[$referenceTableName] = $usedField;
                }
            }
        }
    }

    private function handleForeignColumns($oldRecord, $foreignColumns, &$newRecord)
    {
        foreach ($foreignColumns as $oldForeignColumn => $foreignColumnConfig) {
            $referenceTableName = $foreignColumnConfig['table'];

            foreach ($foreignColumnConfig['mapping_array'] ?? [] as $key => $newColumns) {
                if (!is_array($newColumns)) {
                    $newColumns = [$newColumns];
                }

                if (is_array($newColumns) && isset($newColumns['handler_function'])) {
                    $newColumns = [$newColumns];
                }

                foreach ($newColumns as $newColumn) {
                    $newValue = $this->getForeignValue($oldRecord->{$oldForeignColumn}, $referenceTableName, $key);

                    if ($handlerFunction = $newColumn['handler_function'] ?? '') {
                        $functionArguments = $newColumn['function_args'] ?? '';
                        $new_column = $functionArguments['column'];
                        $newValue = $handlerFunction($oldRecord, $oldForeignColumn, $newRecord, $new_column, $newValue,
                            $functionArguments);
                        $newRecord["$new_column"] = $newValue;
                    } else {
                        $newRecord["$newColumn"] = $newValue;
                    }
                }
            }
        }
    }

    protected function getForeignValue($oldColumnValue, $referenceTableName, $key)
    {
        $oldColumnValue = $this->trimValues(strtolower($oldColumnValue));
        $foreignValue = $this->referenceTables[$referenceTableName][$key][$oldColumnValue] ?? null;

        return $foreignValue;
    }

    private function updateOrInsertGetId($tableBuilder, $conditionArray, $fieldsArray)
    {
        $this->migrationLog('updateOrInsertGetId');

        $record = $tableBuilder
            ->select('id')
            ->where($conditionArray)
            ->first();

        if ($record) {
            $newId = $record->id;
            unset($fieldsArray['created_at']);
            unset($fieldsArray['updated_at']);
            $tableBuilder->where('id', $newId)->update($fieldsArray);
        } else {
            $newId = $tableBuilder->insertGetId($fieldsArray);
        }

        return $newId;
    }

    //TODO: Pivot columns are not taken into consideration
    private function handleManyToManyRelation($objectId, $relationId, $pivotConfigArray)
    {
        $this->migrationLog('handleManyToManyRelation : ' . $objectId);

        $pivotTable = $pivotConfigArray['pivot_table_name'] ?? '';
        $objectColumn = $pivotConfigArray['object_column_name'] ?? '';
        $relationColumn = $pivotConfigArray['relation_column_name'] ?? '';

        $queryBuilder = DB::table($pivotTable);

        $record = $queryBuilder
            ->where($objectColumn, $objectId)
            ->where($relationColumn, $relationId)
            ->first();

        if (!$record) {
            $data = array_merge([
                $objectColumn => $objectId,
                $relationColumn => $relationId
            ], $pivotConfigArray['appended_columns'] ?? []);


            $queryBuilder->insert($data);
        }
    }

    private function insertIntoDataMigrationTable(
        $oldRecord,
        $identifierColumn,
        $oldTable,
        $message = '',
        $processed = true
    )
    {
        $tableReference = $oldRecord->{$identifierColumn};

        $this->migrationLog('insertIntoDataMigrationTable : ' . $message . ' recode: ' . $tableReference);

        try {
            $this->bulkDBLogInsert[] = [
                'config_path' => $this->configPath . '.' . $this->currentConfigPathKey,
                'table_name' => $oldTable,
                'table_reference' => $tableReference,
                'payload' => json_encode((array)$oldRecord),
                'processed' => $processed,
                'message' => $message,
                'created_at' => now(),
            ];

            if (count($this->bulkDBLogInsert) == 200) {
                DB::table('data_migrations')->insert($this->bulkDBLogInsert);
                $this->bulkDBLogInsert = [];
            }
        } catch (\Exception $exception) {
//            report($exception);
            $this->migrationLog($exception->getMessage(), false, 'error');
        }
    }

    public function migrationLog($message, $addToConsole = false, $level = 'info')
    {
        if (config('app.enable_migration_log') || $addToConsole) {
            $this->console->line($message, $level);
        }

        logger()->channel('migration')->log($level, $message);
    }

    protected function validate(&$record, $validations)
    {
        $rules = $validations['rules'];
        $actions = $validations['actions'];

        foreach ($record as $key => $value) {
            if (is_array($record)) {
                $record[$key] = $this->trimValues($value);
            } else {
                $record->{$key} = $this->trimValues($value);
            }
        }

        $validator = Validator::make((array)$record, $rules);

        if (!$validator->passes()) {
            $errors = $validator->errors();
            foreach ($actions as $column => $action) {
                if ($errors->has($column)) {
                    $method = $action['on_fail'] ?? '';

                    if ($action['status'] == 'fail' && !empty($method)) {
                        $functionArguments = $action['on_fail_args'] ?? [];

                        $newValue = $method($record, $column, null, null, null, $functionArguments);

                        //some validations are applied to newRecord which is an array
                        //and some others are applied to oldRecord which is an object

                        if (is_array($record)) {
                            $record["$column"] = $newValue;
                        } else {
                            $record->{$column} = $newValue;
                        }
                        $this->migrationLog("column $column has a validation error and handled with [ " . $action['on_fail'] . "] method handler");
                    } elseif ($action['status'] == 'ignore') {
                        return false;
                    } elseif ($action['status'] != 'continue') {
                        $errorMessage = $errors->getMessageBag()->first($column);

                        throw new \Exception('Validation:[' . $column . '=>' . $rules[$column] . ']::' . $errorMessage);
                    }
                }
            }
        }

        return true;
    }

    protected function trimValues($value)
    {
        if (is_array($value) || is_object($value)) {
            return $value;
        } elseif (is_null($value)) {
            return $value;
        } else {
            return trim($value);
        }
    }

    protected function getRecordsCount($queryBuilder)
    {
        $queryBuilderCloned = clone $queryBuilder;
        if (!empty($queryBuilderCloned->groups)) {
            $distinct = [];

            foreach ($queryBuilderCloned->groups as $group) {
                $distinct[] = $group;
            }

            $queryBuilderCloned->groups = null;

            $result = $queryBuilderCloned->select(DB::raw('count(distinct ' . join(',',
                    $distinct) . ') as count'))->first();

            return $result->count;
        } else {
            return $queryBuilderCloned->count();
        }
    }

    protected function checkNewRecordBeforeInsert(&$newRecord, $configArray)
    {
        if (Arr::get($configArray, 'table_has_timestamp', true)) {
            MigrationHandlers::checkCreatedAndUpdatedAt($newRecord);
        }

        if (Arr::get($configArray, 'table_has_auditable', true)) {
            MigrationHandlers::checkCreatedAndUpdatedBy($newRecord);
        }
    }

}
