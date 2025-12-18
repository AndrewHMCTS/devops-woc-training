def test_upload_file(client):
    payload = {
        "filename": "test.txt",
        "uploaded_by": "pytest",
        "blob_key": "blob/test.txt"
    }

    response = client.post("/upload", json=payload)

    assert response.status_code == 200
    body = response.json()

    assert body["status"] == "success"
    assert body["filename"] == "test.txt"
    assert "id" in body
