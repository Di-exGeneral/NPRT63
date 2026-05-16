import pytest

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{email[:8]}",
        "email": email,
        "phoneNumber": "0812345710",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]

def test_submit_bug_report(client):
    token = get_token(client, "bugresident@example.com", "Resident")
    from app.services.user_service import get_user_by_email
    from app.database import SessionLocal
    db = SessionLocal()
    user = get_user_by_email(db, "bugresident@example.com")
    db.close()
    response = client.post("/bug-reports/", params={"userID": user.userID}, json={
        "title": "App crashes on login",
        "description": "The app crashes every time I try to log in on Android 12"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200

def test_list_bug_reports_as_itstaff(client):
    token = get_token(client, "itstaff@example.com", "ITStaff")
    response = client.get("/bug-reports/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_list_bug_reports_as_resident_forbidden(client):
    token = get_token(client, "bugresidentforbidden@example.com", "Resident")
    response = client.get("/bug-reports/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_bug_report_by_id(client):
    token = get_token(client, "getbug@example.com", "ITStaff")
    response = client.get("/bug-reports/nonexistent-bug", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404