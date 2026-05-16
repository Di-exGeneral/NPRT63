import pytest
import uuid

def get_admin_token(client):
    client.post("/auth/register", json={
        "username": "adminuser",
        "email": "admin@example.com",
        "phoneNumber": "0812345680",
        "password": "AdminPass123",
        "role": "MunicipalAdmin"
    })
    response = client.post("/auth/login", json={
        "email": "admin@example.com",
        "password": "AdminPass123"
    })
    return response.json()["access_token"]

def get_resident_token(client):
    client.post("/auth/register", json={
        "username": "residentuser",
        "email": "resident@example.com",
        "phoneNumber": "0812345681",
        "password": "ResidentPass123",
        "role": "Resident"
    })
    response = client.post("/auth/login", json={
        "email": "resident@example.com",
        "password": "ResidentPass123"
    })
    return response.json()["access_token"]

def test_create_area(client):
    token = get_admin_token(client)
    area_id = f"area-{uuid.uuid4().hex[:8]}"
    response = client.post("/areas/", json={
        "areaID": area_id,
        "suburbName": "Kimberley North",
        "municipalityName": "Sol Plaatje"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200

def test_list_areas(client):
    token = get_resident_token(client)
    response = client.get("/areas/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_area_by_id(client):
    token = get_admin_token(client)
    area_id = f"area-{uuid.uuid4().hex[:8]}"
    client.post("/areas/", json={
        "areaID": area_id,
        "suburbName": "Kimberley South",
        "municipalityName": "Sol Plaatje"
    }, headers={"Authorization": f"Bearer {token}"})
    response = client.get(f"/areas/{area_id}", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["suburbName"] == "Kimberley South"

def test_get_nonexistent_area(client):
    token = get_resident_token(client)
    response = client.get("/areas/nonexistent", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404

def test_create_area_unauthorized(client):
    token = get_resident_token(client)
    area_id = f"area-{uuid.uuid4().hex[:8]}"
    response = client.post("/areas/", json={
        "areaID": area_id,
        "suburbName": "Unauthorised Area",
        "municipalityName": "Sol Plaatje"
    }, headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 403