import pytest
from fastapi.testclient import TestClient

def test_register_user(client):
    import uuid
    unique_email = f"testuser_{uuid.uuid4().hex[:8]}@example.com"
    response = client.post("/auth/register", json={
        "username": "testuser",
        "email": unique_email,
        "phoneNumber": "0812345678",
        "password": "TestPass123",
        "role": "Resident"
    })
    assert response.status_code == 200
    assert "userID" in response.json()

def test_register_duplicate_email(client):
    client.post("/auth/register", json={
        "username": "testuser",
        "email": "duplicate@example.com",
        "phoneNumber": "0812345678",
        "password": "TestPass123",
        "role": "Resident"
    })
    response = client.post("/auth/register", json={
        "username": "testuser2",
        "email": "duplicate@example.com",
        "phoneNumber": "0812345679",
        "password": "TestPass123",
        "role": "Resident"
    })
    assert response.status_code == 400
    assert response.json()["detail"] == "Email already registered"

def test_login_success(client):
    client.post("/auth/register", json={
        "username": "loginuser",
        "email": "loginuser@example.com",
        "phoneNumber": "0812345670",
        "password": "TestPass123",
        "role": "Resident"
    })
    response = client.post("/auth/login", json={
        "email": "loginuser@example.com",
        "password": "TestPass123"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["token_type"] == "bearer"

def test_login_wrong_password(client):
    client.post("/auth/register", json={
        "username": "wrongpass",
        "email": "wrongpass@example.com",
        "phoneNumber": "0812345671",
        "password": "TestPass123",
        "role": "Resident"
    })
    response = client.post("/auth/login", json={
        "email": "wrongpass@example.com",
        "password": "WrongPassword"
    })
    assert response.status_code == 401

def test_login_nonexistent_user(client):
    response = client.post("/auth/login", json={
        "email": "nonexistent@example.com",
        "password": "TestPass123"
    })
    assert response.status_code == 401