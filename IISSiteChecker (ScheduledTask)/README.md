**IISSiteChecker (ScheduleTask) Script**

The `IISSiteChecker (ScheduleTask)` script is designed for automated, scheduled checks of website statuses on IIS servers.

Key Features:
- Automated Monitoring: Schedule regular checks for website statuses on IIS servers.
- Server List Support: Works with a list of servers provided in `ServerList.txt`.
- Report Generation: Outputs status reports at scheduled intervals.

Usage:
1. Place the script and `ServerList.txt` in the same directory.
2. Populate `ServerList.txt` with the server names you want to monitor.
3. Schedule the script to run at desired intervals using Windows Task Scheduler.

Note: Ensure the script is configured with the correct permissions for scheduled execution.