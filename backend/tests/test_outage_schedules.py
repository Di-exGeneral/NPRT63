import pytest
from datetime import datetime, timedelta

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{role}_{email[:5]}",
        "email": email,
        "phoneNumber": "0812345695",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]
def test_create_schedule(client):
    import uuid
    from app.services.user_service import get_user_by_email
    from app.database import SessionLocal
    area_id = f"area-schedule-{uuid.uuid4().hex[:8]}"
    schedule_id = f"schedule-{uuid.uuid4().hex[:8]}"
    admin_token = get_token(client, "scheduleadmin@example.com", "MunicipalAdmin")
    db = SessionLocal()
    admin_user = get_user_by_email(db, "scheduleadmin@example.com")
    db.close()
    client.post("/areas/", json={
        "areaID": area_id,
        "suburbName": "Schedule Area",
        "municipalityName": "Test Municipality"
    }, headers={"Authorization": f"Bearer {admin_token}"})
    response = client.post("/outage-schedules/", json={
        "scheduleID": schedule_id,
        "areaID": area_id,
        "startTime": (datetime.utcnow() + timedelta(days=1)).isoformat(),
        "endTime": (datetime.utcnow() + timedelta(days=1, hours=4)).isoformat(),
        "description": "Planned maintenance",
        "status": "Scheduled",
        "createdBy": admin_user.userID
    }, headers={"Authorization": f"Bearer {admin_token}"})
    assert response.status_code == 200

def test_list_schedules(client):
    token = get_token(client, "scheduleresident@example.com", "Resident")
    response = client.get("/outage-schedules/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_schedule_as_resident_forbidden(client):
    token = get_token(client, "scheduleresidentforbidden@example.com", "Resident")
    response = client.post("/outage-schedules/", json={
        "scheduleID": "schedule-002",
        "areaID": "area-schedule-001",
        "startTime": (datetime.utcnow() + timedelta(days=2)).isoformat(),
        "endTime": (datetime.utcnow() + timedelta(days=2, hours=4)).isoformat(),
        "status": "Scheduled",
        "createdBy": "user-resident-001"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_schedules_by_area(client):
    token = get_token(client, "schedulebyarea@example.com", "Resident")
    response = client.get("/outage-schedules/area/area-schedule-001", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_delete_schedule_as_admin(client):
    admin_token = get_token(client, "deletescheduleadmin@example.com", "MunicipalAdmin")
    response = client.delete("/outage-schedules/schedule-001", headers={"Authorization": f"Bearer {admin_token}"})
    assert response.status_code == 200