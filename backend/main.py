from fastapi import FastAPI
from app.routes import auth
from app.routes import user
from app.routes import areas
from app.routes import fault_reports
from app.routes import outage_schedules
from app.routes import maintenance
from app.routes import bug_reports
from app.routes import audit_logs
from app.routes import notifications
from app.routes import alerts
from app.routes import dashboard
import logging
from app.database import engine
from app.models.emergency_alert import EmergencyAlert

app = FastAPI(title="HydroAlert API", version="1.0.0")

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(user.router, prefix="/users", tags=["Users"])
app.include_router(areas.router, prefix="/areas", tags=["Areas"])
app.include_router(fault_reports.router, prefix="/fault-reports", tags=["Fault Reports"])
app.include_router(outage_schedules.router, prefix="/outage-schedules", tags=["Outage Schedules"])
app.include_router(maintenance.router, prefix="/maintenance", tags=["Maintenance"])
app.include_router(bug_reports.router, prefix="/bug-reports", tags=["Bug Reports"])
app.include_router(audit_logs.router, prefix="/audit-logs", tags=["Audit Logs"])
app.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
app.include_router(alerts.router, prefix="/alerts", tags=["Emergency Alerts"])
app.include_router(dashboard.router, prefix="/dashboard", tags=["Dashboard"])

@app.on_event("startup")
def ensure_new_tables():
    try:
        EmergencyAlert.__table__.create(bind=engine, checkfirst=True)
    except Exception:
        logging.exception("Could not create emergencyalert table")

@app.get("/")
def root():
    return {"message": "HydroAlert API is running"}
