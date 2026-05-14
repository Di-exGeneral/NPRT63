from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_root_endpoint():
    """Test that the root endpoint returns correct response"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "HydroAlert API is running"}

def test_api_title():
    """Test that API is properly initialized"""
    assert app.title == "HydroAlert API"
    assert app.version == "1.0.0"