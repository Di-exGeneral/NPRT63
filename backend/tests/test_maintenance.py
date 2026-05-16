import pytest

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{email[:8]}",
        "email": email,
        "phoneNumber": "0812345700",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]

def test_assign_maintenance_team(client):
    token = get_token(client, "assignadmin@example.com", "MunicipalAdmin")
    response = client.post("/maintenance/assign", params={
        "reportID": "report-001",
        "teamID": "team-001",
        "assignedBy": "admin-001"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code in [200, 404]

def test_assign_as_resident_forbidden(client):
    token = get_token(client, "assignresident@example.com", "Resident")
    response = client.post("/maintenance/assign", params={
        "reportID": "report-001",
        "teamID": "team-001",
        "assignedBy": "resident-001"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_team_assignments(client):
    token = get_token(client, "teamassignments@example.com", "MaintenanceTeam")
    response = client.get("/maintenance/team/team-001", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200

def test_get_report_assignment(client):
    token = get_token(client, "reportassignment@example.com", "MunicipalAdmin")
    response = client.get("/maintenance/report/report-001", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200