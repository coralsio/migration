<?php

namespace Corals\Modules\Migration\Providers;

use Corals\Foundation\Providers\BaseUpdateModuleServiceProvider;

class UpdateModuleServiceProvider extends BaseUpdateModuleServiceProvider
{
    protected $module_code = 'corals-migration';
    protected $batches_path = __DIR__ . '/../update-batches/*.php';
}
