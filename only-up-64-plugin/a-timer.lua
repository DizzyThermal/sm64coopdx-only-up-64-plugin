function reset_timer()
    _G.ou64_run_timer_running = false
    _G.ou64_run_timer_start_time = 0
    gPlayerSyncTable[0].run_time = 0
end
