import pytest

def get_token(client, email, role):
    client.post("/auth/register", json={
        "username": f"user_{email[:8]}",
        "email": email,
        "phoneNumber": "0812345730",
        "password": "TestPass123",
        "role": role
    })
    response = client.post("/auth/login", json={
        "email": email,
        "password": "TestPass123"
    })
    return response.json()["access_token"]

def test_list_users_as_itstaff(client):
    token = get_token(client, "listusersit@example.com", "ITStaff")
    response = client.get("/users/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_list_users_as_resident_forbidden(client):
    token = get_token(client, "listusersresident@example.com", "Resident")
    response = client.get("/users/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403

def test_get_user_by_id(client):
    token = get_token(client, "getuserit@example.com", "ITStaff")
    response = client.get("/users/nonexistent-id", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404

def test_delete_user_as_itstaff(client):
    token = get_token(client, "deleteuserit@example.com", "ITStaff")
    response = client.delete("/users/nonexistent-id", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200

def test_delete_user_as_resident_forbidden(client):
    token = get_token(client, "deleteuserresident@example.com", "Resident")
    response = client.delete("/users/some-id", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403