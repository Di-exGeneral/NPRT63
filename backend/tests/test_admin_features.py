import uuid
from datetime import datetime, timedelta


def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{email[:8]}",
        "email": email,
        "phoneNumber": "0812345800",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={"email": email, "password": "TestPass123"})
    return response.json()["access_token"]


def auth(token):
    return {"Authorization": f"Bearer {token}"}


def make_area(client, token):
    area_id = f"area-{uuid.uuid4().hex[:8]}"
    client.post("/areas/", json={"areaID": area_id, "suburbName": "Alert Suburb", "municipalityName": "Test Municipality"}, headers=auth(token))
    return area_id


def make_resident_in_area(client, area_id):
    email = f"res{uuid.uuid4().hex[:8]}@example.com"
    token = get_token(client, email, "Resident")
    client.patch("/areas/me/area", json={"areaID": area_id}, headers=auth(token))
    return token


def test_emergency_alert_notifies_area_residents(client):
    admin = get_token(client, "alertadmin@example.com", "MunicipalAdmin")
    area_id = make_area(client, admin)
    resident = make_resident_in_area(client, area_id)
    response = client.post("/alerts/", json={
        "areaID": area_id,
        "alertType": "Water Contamination",
        "message": "Boil water before use",
        "estimatedDuration": "2-4 hours",
        "channels": ["push"]
    }, headers=auth(admin))
    assert response.status_code == 200
    body = response.json()
    assert body["recipientCount"] == 1
    assert body["areaName"] == "Alert Suburb"

    notifications = client.get("/notifications/", headers=auth(resident)).json()
    assert any(n["type"] == "emergency" and "Boil water" in n["message"] for n in notifications)

    alerts = client.get("/alerts/", headers=auth(admin)).json()
    assert any(a["alertID"] == body["alertID"] for a in alerts)


def test_emergency_alert_unknown_area(client):
    admin = get_token(client, "alertadmin2@example.com", "MunicipalAdmin")
    response = client.post("/alerts/", json={"areaID": "missing-area", "alertType": "Burst", "message": "x", "channels": []}, headers=auth(admin))
    assert response.status_code == 404


def test_emergency_alert_forbidden_for_resident(client):
    token = get_token(client, "alertresident@example.com", "Resident")
    response = client.post("/alerts/", json={"areaID": "a", "alertType": "Burst", "message": "x"}, headers=auth(token))
    assert response.status_code == 403


def test_dashboard_summary(client):
    admin = get_token(client, "dashadmin@example.com", "MunicipalAdmin")
    response = client.get("/dashboard/summary", headers=auth(admin))
    assert response.status_code == 200
    body = response.json()
    for key in ["totalReports", "reportsByStatus", "ongoingOutages", "upcomingOutages", "areas", "maintenanceTeams", "alertsSent"]:
        assert key in body


def test_dashboard_forbidden_for_resident(client):
    token = get_token(client, "dashresident@example.com", "Resident")
    assert client.get("/dashboard/summary", headers=auth(token)).status_code == 403


def test_list_maintenance_teams(client):
    admin = get_token(client, "teamsadmin@example.com", "MunicipalAdmin")
    get_token(client, "teamsworker@example.com", "MaintenanceTeam")
    response = client.get("/maintenance/teams", headers=auth(admin))
    assert response.status_code == 200
    assert any(t["email"] == "teamsworker@example.com" for t in response.json())


def test_edit_schedule_and_notify(client):
    admin = get_token(client, "editscheduleadmin@example.com", "MunicipalAdmin")
    me = client.get("/users/me", headers=auth(admin)).json()
    area_id = make_area(client, admin)
    resident = make_resident_in_area(client, area_id)
    start = datetime.utcnow() + timedelta(days=1)
    created = client.post("/outage-schedules/", json={
        "scheduleID": "ignored",
        "areaID": area_id,
        "startTime": start.isoformat(),
        "endTime": (start + timedelta(hours=4)).isoformat(),
        "description": "Pipe replacement",
        "status": "Scheduled",
        "createdBy": me["userID"]
    }, headers=auth(admin)).json()
    schedule_id = created["scheduleID"]

    response = client.put(f"/outage-schedules/{schedule_id}", json={"endTime": (start + timedelta(hours=6)).isoformat(), "description": "Extended"}, headers=auth(admin))
    assert response.status_code == 200
    assert response.json()["description"] == "Extended"

    bad = client.put(f"/outage-schedules/{schedule_id}", json={"endTime": (start - timedelta(hours=1)).isoformat()}, headers=auth(admin))
    assert bad.status_code == 400

    types = [n["type"] for n in client.get("/notifications/", headers=auth(resident)).json()]
    assert types.count("outage") >= 2


def test_edit_area(client):
    admin = get_token(client, "editareaadmin@example.com", "MunicipalAdmin")
    area_id = make_area(client, admin)
    response = client.put(f"/areas/{area_id}", json={"suburbName": "Renamed", "municipalityName": "Muni"}, headers=auth(admin))
    assert response.status_code == 200
    assert response.json()["suburbName"] == "Renamed"
