from app.services.auth_service import hash_password, verify_password, create_access_token, decode_access_token
from app.services.user_service import create_user, get_user_by_email, get_user_by_id, get_all_users, delete_user
from app.services.area_service import create_area, get_all_areas, get_area_by_id
from app.services.fault_report_service import create_fault_report, get_all_fault_reports, get_fault_report_by_id, get_reports_by_resident, update_fault_report_status, get_report_history
from app.services.outage_schedule_service import create_outage_schedule, get_all_schedules, get_schedules_by_area, get_schedule_by_id, update_schedule_status, delete_schedule
from app.services.maintenance_service import create_assignment, get_assignments_by_team, get_assignment_by_report
from app.services.bug_report_service import create_bug_report, get_all_bug_reports, get_bug_report_by_id, update_bug_status
from app.services.audit_service import log_action, get_all_logs, get_logs_by_user
from app.services.s3_service import upload_photo, delete_photo