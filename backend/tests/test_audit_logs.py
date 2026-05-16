import pytest

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{email[:8]}",
        "email": email,
        "phoneNumber": "0812345720",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]

def test_list_logs_as_itstaff(client):
    token = get_token(client, "auditit@example.com", "ITStaff")
    response = client.get("/audit-logs/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_list_logs_as_resident_forbidden(client):
    token = get_token(client, "auditresident@example.com", "Resident")
    response = client.get("/audit-logs/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_logs_by_user(client):
    token = get_token(client, "auditbyuser@example.com", "ITStaff")
    response = client.get("/audit-logs/user/some-user-id", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)