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

app = FastAPI(title="HydroAlert API", version="1.0.0")

app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(user.router, prefix="/users", tags=["Users"])
app.include_router(areas.router, prefix="/areas", tags=["Areas"])
app.include_router(fault_reports.router, prefix="/fault-reports", tags=["Fault Reports"])
app.include_router(outage_schedules.router, prefix="/outage-schedules", tags=["Outage Schedules"])
app.include_router(maintenance.router, prefix="/maintenance", tags=["Maintenance"])
app.include_router(bug_reports.router, prefix="/bug-reports", tags=["Bug Reports"])
app.include_router(audit_logs.router, prefix="/audit-logs", tags=["Audit Logs"])
app.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])

@app.get("/")
def root():
    return {"message": "HydroAlert API is running"}
