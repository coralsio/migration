<?php

namespace Corals\Modules\Migration\Classes;


use Carbon\Carbon;
use Illuminate\Support\Str;


class MigrationHandlers
{
    /**
     * @param $oldRecord
     * @param $oldColumn
     * @param $newRecord
     * @param $newColumn
     * @param null $newValue
     * @param array $args
     * @return string
     */
    public static function casts($oldRecord, $oldColumn, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        $value = $newValue ?? $oldRecord->{$oldColumn};

        switch ($args['type']) {
            case 'date':
                $value = Carbon::parse($value)->format('Y-m-d');
                break;
            case 'ucfirst':
                $value = ucfirst(strtolower($value));
                break;
            case 'datetime':
                $value = Carbon::parse($value)->toDateTimeString();
                break;
            case 'lowercase':
                $value = strtolower($value);
                break;
            case 'title':
                $value = Str::title($value);
                break;
        }

        return $value;
    }

    public static function mapToBoolean($oldRecord, $oldColumn)
    {
        return in_array($oldRecord->{$oldColumn}, ['Y', 'y', 'Yes', 'yes', 'true']);
    }


    public static function strLimit($oldRecord, $oldColumn, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        $oldValue = $oldRecord->{$oldColumn};
        $length = $args['length'];
        return \Str::limit($oldValue, $length);

    }

    public static function compareValue($oldRecord, $oldColumn, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        $oldValue = $oldRecord->{$oldColumn};
        $method = $args['method'];
        $mapping = $args['mapping'] ?? [];

        if ($method == 'isNull') {
            if ($oldValue) {
                return $mapping[1];
            } else {
                return $mapping[0];
            }


        } else if ($method == 'mapToBoolean') {
            $trueArray = ['Y', 'y', 'Yes', 'yes'];
            $falseArray = ['No', 'no', 'N', 'n'];

            if (in_array($oldValue, $trueArray)) {
                return 1;
            } elseif (in_array($oldValue, $falseArray)) {
                return 0;
            }
            return 0;
        } else if ($method == 'priority') {
            switch ($oldValue) {
                case '1':
                    $newValue = $mapping[1];
                    break;
                case 2:
                    $newValue = $mapping[2];
                    break;
                case 3:
                    $newValue = $mapping[3];
                    break;
                case 4 :
                    $newValue = $mapping[4];
                    break;
                default:
                    $newValue = $mapping[2];
            }

            return $newValue;
        }

    }


    public static function setToNull()
    {
        return null;
    }

    public static function toJsonColumn($oldRecord, $oldColumn, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        //foreign means it's coming from foreignKey and the reference is null (( flag like ))
        $isForeignKey = $args['is_foreign_key'] ?? false;
        $value = $args['value'] ?? null;

        if (!empty($value)) {
            $newValue = $value;

        } else {
            if ($isForeignKey && is_null($newValue)) {
                $newValue = null;
            } else if (is_null($newValue)) {
                $newValue = $oldRecord->{$oldColumn};
            }
        }


        $path = $args['path'];

        $array = $newRecord["$newColumn"] ?? [];

        if (!empty($newValue)) {
            \Arr::set($array, $path, $newValue);
        }

        return $array;
    }

    public static function splitFirstAndLastNameIntoArray($oldRecord, $oldColumn, $newRecord, $newColumn)
    {
        $array = $newRecord[$newColumn] ?? [];

        $fullName = explode(' ', $oldRecord->{$oldColumn});

        $index = count($array);

        if (!empty($fullName[0])) {
            \Arr::set($array, $index . '.first_name', $fullName[0] ?? '');
        }
        if (!empty($fullName[1])) {
            \Arr::set($array, $index . '.last_name', $fullName[1] ?? '');
        }

        return $array;
    }


    public static function applySubQueries($query, $conditions)
    {
        foreach ($conditions as $condition) {
            $operation = $condition['operation'] ?? '';
            $method = $condition['method'] ?? 'where';
            $column = $condition['column'] ?? null;
            $value = $condition['value'] ?? '';

            switch ($method) {
                case 'where':
                case 'orWhere':
                    switch ($operation) {
                        case 'In':
                        case 'NotIn':
                            $query = $query->{$method . $operation}($column, $value);
                            break;
                        case 'Null' :
                        case 'NotNull':
                            $query = $query->{$method . $operation}($column);
                            break;
                        default:
                            $query = $query->{$method}($column, $operation, $value);
                    }
                    break;
                case 'whereRaw':
                    $query = $query->{$method}($value);
                    break;
                case 'groupBy':
                    $query = $query->{$method}($column);
                    break;
            }
        }

        return $query;
    }

    public static function handleExtraQueries($queryBuilder, $queryConfig)
    {
        $joins = $queryConfig['joins'] ?? [];
        $selects = $queryConfig['selects'] ?? [];

        if ($joins) {
            static::joins($queryBuilder, $joins);
        }

        if ($selects) {
            static::selects($queryBuilder, $selects);
        }

        return $queryBuilder;
    }

    protected static function joins(&$queryBuilder, $joins)
    {
        foreach ($joins as $joinType => $join) {

            $table = $join['table'];
            $operation = $join['operation'] ?? '=';
            $table1_column = $join['table1_column'];
            $table2_column = $join['table2_column'];

            switch ($joinType) {
                case 'join':
                case 'innerJoin':
                    $joinMethod = 'join';
                    break;
                case 'leftJoin':
                    $joinMethod = 'leftJoin';
                    break;
                default:
                    $joinMethod = 'join';
            }

            $queryBuilder->{$joinMethod}($table, $table1_column, $operation, $table2_column);
        }
    }

    protected static function selects(&$queryBuilder, $columns)
    {
        $queryBuilder->addSelect($columns);
    }

    public static function setDateIfOldColumnNull($record, $column, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        //handle if it's been called from validate function or from handler_function
        //in validate function one record will be sent either new record or old record
        if (empty($newRecord)) {
            $newRecord = $record;
        }
        //handle if want to set from new column
        if ($fromNewColumn = $args['from_new_column'] ?? '') {
            return $newRecord["$fromNewColumn"];
        } else {
            //handle if want to set from old column
            $fromColumn = $args['from_old_column'];
            if (!$record->{$column} || $record->{$column} == '0000-00-00') {
                return $record->{$fromColumn};
            }
        }

        return $record->{$column};
    }

    public static function checkCreatedAndUpdatedBy(&$newRecord)
    {
        $newRecord['created_by'] = empty($newRecord['created_by']) ? self::setToNaEmployee() : $newRecord['created_by'];
        $newRecord['updated_by'] = empty($newRecord['updated_by']) ? $newRecord['created_by'] : $newRecord['updated_by'];
    }

    public static function checkCreatedAndUpdatedAt(&$newRecord)
    {
        $newRecord['created_at'] = empty($newRecord['created_at']) ? self::setToNow() : $newRecord['created_at'];
        $newRecord['updated_at'] = empty($newRecord['updated_at']) ? $newRecord['created_at'] : $newRecord['updated_at'];

    }

    public static function setToNaEmployee()
    {
        return 2;
    }

    public static function setAlternativeEmailFrom($oldRecord, $oldColumn, $newRecord, $newColumn, $newValue = null, $args = [])
    {
        $alternativeEmailColumn = $args['alternative_email_column'];

        if ($alternativeEmail = $oldRecord->{$alternativeEmailColumn}) {
            return $alternativeEmail;
        } else {
            throw new \Exception('Email and Alternative Emails are missing');
        }
    }

    public static function setToNow()
    {
        return now();
    }

    public static function setToNAState()
    {
        return 'n_a';
    }

    public static function setToUSACountry()
    {
        return 'US';
    }

    public static function getReferenceTableAsPluckArray($mapArray, $table, $columns)
    {
        if (empty($mapArray)) {
            $mapArray = \DB::table($table)
                ->pluck($columns[0], $columns[1])
                ->toArray();
        }
        return $mapArray;
    }

    public static function formatPhoneNumber($oldRecord, $oldColumn)
    {
        return tap(getCleanedPhoneNumber($oldRecord->{$oldColumn}), function (&$cleanPhoneNumber) {
            if (!empty($cleanPhoneNumber)) {
                $cleanPhoneNumber = getFormattedPhoneNumber($cleanPhoneNumber);
            } else {
                $cleanPhoneNumber = null;
            }
        });
    }
}
