<?php

namespace Corals\Modules\Migration\Classes;


use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;


class MigrationHandlers
{
    /**
     * @var
     */
    protected static $codeSetsTable;

    /**
     * @var
     */
    protected static $j9Table;
    protected static $j1Table;
    protected static $j3Table;
    protected static $j8Table;

    protected static $marketSegmentsParent;

    /**
     * @var
     */
    protected static $naStateCodeId;

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

    public static function setToNA()
    {
        return 'NA';
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

    /**
     * @return string
     */
    public static function setToPhoneNumberPlaceholder()
    {
        return '000-000-0000';
    }

    /**
     * @return string
     */
    public static function setToNoEmail()
    {
        return 'noemail@email.com';
    }

    /**
     * @param $oldRecord
     * @param $oldColumn
     * @return string
     */
    public static function mapStatusAsActiveInactive($oldRecord, $oldColumn): string
    {
        $value = strtolower($oldRecord->{$oldColumn} ?? 'active');

        return in_array($value, ['i']) ? 'Inactive' : 'Active';
    }

    /**
     * @param $oldRecord
     * @param $oldForeignColumn
     * @param $newRecord
     * @param $new_column
     * @param $newValue
     * @param $functionArguments
     * @return \Illuminate\Container\Container|mixed|object
     */
    public static function setToNaCodeId($oldRecord,
                                         $oldForeignColumn,
                                         $newRecord,
                                         $new_column,
                                         $newValue,
                                         $functionArguments)
    {
        if ($newValue) {
            return $newValue;
        }

        if (static::$naStateCodeId) {
            return static::$naStateCodeId;
        }

        static::$naStateCodeId = DB::connection('mysql_migration_new')
            ->table('code_sets')
            ->where([
                'parent_id' => 1,
                'code' => 'NA'
            ])->value('id');

        return static::$naStateCodeId;
    }

    /**
     * @param $oldRecord
     * @param $oldColumn
     * @return string
     */
    public static function mapCreditCardType($oldRecord, $oldColumn)
    {
        $value = $oldRecord->{$oldColumn};

        //TODO::what to do in case of Null and ((AD,Other))
        if (!$value) return $value;

//        enum('visa', 'mastercard', 'amex', 'diners', 'discover', 'jcb', 'unionpay', 'electron', 'maestro', 'dankort', 'interpayment')
        return match (strtolower($value)) {
            'visa' => 'visa',
            'discover' => 'discover',
            'amex' => 'amex',
            'mastercard' => 'mastercard',
            'diners club' => 'diners',
            default => 'other'
        };
    }

    /**
     * @param $oldRecord
     * @param $oldColumn
     * @return string
     */
    public static function mapPaymentMethod($oldRecord, $oldColumn)
    {
        $value = $oldRecord->{$oldColumn};

        return $value ? 'CC' : 'Check';
    }

    /**
     * @param $oldRecord
     * @param $newRecord
     */
    public static function preStoreCustomerRecord($oldRecord, &$newRecord)
    {
        if (!static::$codeSetsTable) {
            static::$codeSetsTable = DB::table('code_sets')->select([
                'code',
                'id',
                'parent_id'
            ])->get();
        }

        if (!static::$j9Table) {
            static::$j9Table = DB::connection('mysql_migration_old')
                ->table('jcusf09')
                ->select(['ACCTTYPE', 'CUSTNUM', 'CUSTMAST', 'TERMS'])
                ->get();
        }

        if (!static::$j1Table) {
            static::$j1Table = DB::connection('mysql_migration_old')
                ->table('jcusf01_sites_dbf')
                ->select(['ACCTTYPE', 'CUSTNUM', 'CUSTMAST', 'CCARDTYPE', 'LLCCBILL', 'STATEPRNT'])
                ->get();
        }

        if (!static::$j3Table) {
            static::$j3Table = DB::connection('mysql_migration_old')
                ->table('jreff03')
                ->select(['LATEDOL', 'COCODE'])
                ->get();
        }

        $lateCharge = static::$j3Table->firstWhere('COCODE', $oldRecord->BLLCOCODE);


        if ($lateCharge) {
            $newRecord['late_charge'] = $lateCharge->LATEDOL;
        }

        if (!static::$j8Table) {
            static::$j8Table = DB::connection('mysql_migration_old')
                ->table('jcusf08')
                ->select(['CUSTMAST', 'NTCODE'])
                ->get();
        }

        $j9LowestCustNum = static::$j9Table->where('CUSTMAST', $oldRecord->BLLMAST)->sortBy('CUSTNUM')->first();
        $j1LowestCustNum = static::$j1Table->where('CUSTMAST', $oldRecord->BLLMAST)->sortBy('CUSTNUM')->first();
        $j8LowestCustNum = static::$j8Table->where('CUSTMAST', $oldRecord->BLLMAST)->sortBy('CUSTNUM')->first();

        if ($j8LowestCustNum) {
            $newRecord['customer_note_type'] = $j8LowestCustNum->NTCODE;
        }

        if (!static::$marketSegmentsParent) {
            static::$marketSegmentsParent = static::$codeSetsTable->firstWhere('code', 'market_segments');
        }

        if ($j1LowestCustNum) {
            $newRecord['payment_method'] = $j1LowestCustNum->CCARDTYPE <> '' && $j1LowestCustNum->LLCCBILL == 1 ? 'CC' : 'Check';
            $newRecord['invoice_method_statement'] = $j1LowestCustNum->STATEPRNT = 'Y' ? 1 : 0;

            $newRecord['card_type'] = $j1LowestCustNum->CCARDTYPE <> '' ? strtolower($j1LowestCustNum->CCARDTYPE) : null;

            switch ($newRecord['card_type']) {
                case 'MC':
                    $newRecord['card_type'] = 'mastercard';
                    break;
                case 'DISC':
                case 'discovery':
                    $newRecord['card_type'] = 'discover';
                    break;
                case 'FALSE':
                    $newRecord['card_type'] = 'visa';
                    break;
            }
        }

        if ($j9LowestCustNum) {
            $newRecord['customer_market_segment_id'] = static::$codeSetsTable
                    ->where('parent_id', static::$marketSegmentsParent->id)
                    ->firstWhere('code', $j9LowestCustNum->ACCTTYPE)
                    ->id ?? static::$marketSegmentsParent->id;

            $terms = $j9LowestCustNum->TERMS;

            if (!$terms) {
                $newRecord['billing_terms'] = 'DOR';
            } else {
                $newRecord['billing_terms'] = Str::of($j9LowestCustNum->TERMS)
                    ->startsWith('NET')
                    ? $j9LowestCustNum->TERMS
                    : 'DOR';
            }

            switch ($newRecord['billing_terms']) {
                case 'NET':
                case 'NETT':
                case 'CHARGE':
                case 'CC':
                    $newRecord['billing_terms'] = 'NET30';
                    break;
                case 'NET20':
                case 'NET 15':
                case 'NET 5':
                    $newRecord['billing_terms'] = 'NET15';
                    break;
                case 'NET 10':
                    $newRecord['billing_terms'] = 'NET10';
                    break;
            }
        }

        $contact1FirstName = data_get($newRecord, 'contact_1_first_name');

        if ($contact1FirstName && $contact1FirstName <> 'NA' && Str::contains($contact1FirstName, ' ')) {
            $newRecord['contact_1_first_name'] = Str::of($contact1FirstName)->before(' ')->__toString();
            $newRecord['contact_1_last_name'] = Str::of($contact1FirstName)->after(' ')->__toString();
        }

        if (empty($newRecord['customer_market_segment_id'])) {
            $newRecord['customer_market_segment_id'] = static::$marketSegmentsParent->id;
        }
    }
}
