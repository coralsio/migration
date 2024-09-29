<?php

namespace Corals\Modules\Migration\Classes;

class Migration
{
    /**
     * Migration constructor.
     */
    function __construct()
    {
    }

    public function getMicroTimeDuration($startTime, $endTime = null, $seconds = false)
    {
        if (is_null($endTime)) {
            $endTime = microtime(true);
        }

        $duration = $endTime - $startTime;

        if ($seconds) {
            $hours = (int)($duration / 60 / 60);
            $minutes = (int)($duration / 60) - ($hours * 60);

            $result = (float)$duration - ($hours * 60 * 60) - ($minutes * 60);
        } else {
            $result = $duration;
        }

        return $result;
    }
}
