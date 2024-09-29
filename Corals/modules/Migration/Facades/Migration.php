<?php

namespace Corals\Modules\Migration\Facades;

use Illuminate\Support\Facades\Facade;

class Migration extends Facade
{
    /**
     * @return mixed
     */
    protected static function getFacadeAccessor()
    {
        return \Corals\Modules\Migration\Classes\Migration::class;
    }
}
