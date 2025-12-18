def test_list_files(client):
    client.post(
        "/upload",
        json={
            "filename": "file1.txt",
            "uploaded_by": "pytest"
        })

    response = client.get("/files")

    assert response.status_code == 200
    data = response.json()

    assert len(data) == 1
    assert data[0]["name"] == "file1.txt"
    assert data[0]["deleted"] is False
