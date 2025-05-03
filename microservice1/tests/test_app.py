import json
import time
from flask import Flask
import pytest
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import app

@pytest.fixture
def client():
    app.app.config['TESTING'] = True
    with app.app.test_client() as client:
        yield client

def test_health_check(client):
    # Test the health check.
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b'OK'

def test_empty_request(client):
    """Test request with no data."""
    response = client.post('/send-email')
    assert response.status_code == 415  # Unsupported Media Type

def test_missing_fields(client):
    # Test request with an empty json.
    response = client.post('/send-email', 
                         json={},
                         content_type='application/json')
    assert response.status_code == 400
    
    # Missing token
    response = client.post('/send-email', 
                         json={"data": {"email_timestream": "123456789"}},
                         content_type='application/json')
    assert response.status_code == 400
    
    # Missing data
    response = client.post('/send-email', 
                         json={"token": "test-token"},
                         content_type='application/json')
    assert response.status_code == 400

def test_invalid_timestream_format():
    # Test timestream validation function
    assert app.is_valid_timestream(int(time.time())) == True
    assert app.is_valid_timestream(str(int(time.time()))) == True
    assert app.is_valid_timestream("1622505600") == True  # 2021-06-01
    
    # Test timestream invalid inputs
    assert app.is_valid_timestream(None) == False
    assert app.is_valid_timestream("") == False
    assert app.is_valid_timestream("abc") == False
    assert app.is_valid_timestream("-123") == False
    assert app.is_valid_timestream("999999999999999") == False

