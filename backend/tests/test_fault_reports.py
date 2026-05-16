import pytest
import uuid

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{role}",
        "email": email,
        "phoneNumber": "0812345690",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]

def get_resident_id(client, email):
    from app.services.user_service import get_user_by_email
    from app.database import SessionLocal
    db = SessionLocal()
    user = get_user_by_email(db, email)
    db.close()
    from app.models.resident import Resident
    db = SessionLocal()
    resident = db.query(Resident).filter(Resident.userID == user.userID).first()
    db.close()
    return resident.residentID if resident else None

def test_submit_fault_report(client):
    email = f"faultresident_{uuid.uuid4().hex[:6]}@example.com"
    admin_email = f"faultadmin_{uuid.uuid4().hex[:6]}@example.com"
    token = get_token(client, email, "Resident")
    admin_token = get_token(client, admin_email, "MunicipalAdmin")
    area_id = f"area-fault-{uuid.uuid4().hex[:8]}"
    report_id = f"report-{uuid.uuid4().hex[:8]}"
    client.post("/areas/", json={
        "areaID": area_id,
        "suburbName": "Test Area",
        "municipalityName": "Test Municipality"
    }, headers={"Authorization": f"Bearer {admin_token}"})
    resident_id = get_resident_id(client, email)
    assert resident_id is not None, "Resident record was not created on registration"
    response = client.post("/fault-reports/", json={
        "reportID": report_id,
        "residentID": resident_id,
        "areaID": area_id,
        "description": "Burst pipe on main street",
        "location": "123 Main Street"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200

def test_list_fault_reports_as_admin(client):
    token = get_token(client, "listreportsadmin@example.com", "MunicipalAdmin")
    response = client.get("/fault-reports/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_list_fault_reports_as_resident_forbidden(client):
    token = get_token(client, "listreportsresident@example.com", "Resident")
    response = client.get("/fault-reports/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_fault_report_by_id(client):
    token = get_token(client, "getreport@example.com", "MunicipalAdmin")
    response = client.get("/fault-reports/report-001", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code in [200, 404]

def test_get_nonexistent_report(client):
    token = get_token(client, "getnonexistent@example.com", "MunicipalAdmin")
    response = client.get("/fault-reports/nonexistent-id", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404