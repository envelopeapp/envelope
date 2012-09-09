Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 20
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 7.minutes
Delayed::Worker.read_ahead = 15
Delayed::Worker.delay_jobs = !Rails.env.test?
