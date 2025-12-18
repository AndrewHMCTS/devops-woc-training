# tests/test_delete.py
def test_delete_file(client):
    # upload file
    upload = client.post(
        "/upload",
        json={
            "filename": "delete_me.txt",
            "uploaded_by": "pytest"
        }
    )
    file_id = upload.json()["id"]

    # delete file
    response = client.post(f"/delete/?file_id={file_id}")

    assert response.status_code == 200
    assert response.json()["status"] == "deleted"
    assert response.json()["file_id"] == file_id
