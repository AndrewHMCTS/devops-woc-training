from locust import HttpUser, task, between
import random
import string

def random_filename(length=8):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length)) + ".txt"

class BackendUser(HttpUser):
    host = "https://devopswoc-backend.azurewebsites.net" 
    wait_time = between(1, 3)

    @task(3)
    def upload_file(self):
        filename = random_filename()
        uploaded_by = f"user_{random.randint(1,100)}"

        payload = {
            "filename": filename,
            "uploaded_by": uploaded_by
        }

        with self.client.post("/upload", json=payload, catch_response=True) as resp:
            if resp.status_code == 200:
                try:
                    data = resp.json()
                    file_id = data.get("id")
                    if file_id:
                        self.delete_file_id = file_id
                    resp.success()
                except Exception:
                    resp.failure("Upload response not JSON")
            else:
                resp.failure(f"Upload failed with status code {resp.status_code}")

    @task(2)
    def list_files(self):
        with self.client.get("/files", catch_response=True) as resp:
            if resp.status_code == 200:
                try:
                    files = resp.json()
                    if files:
                        self.delete_file_id = random.choice(files).get("id")
                    resp.success()
                except Exception:
                    resp.failure("List files response not JSON")
            else:
                resp.failure(f"List files failed with status code {resp.status_code}")

    @task(1)
    def delete_file(self):
        file_id = getattr(self, "delete_file_id", None)
        if not file_id:
            return

        with self.client.post("/delete/", params={"file_id": file_id}, catch_response=True) as resp:
            if resp.status_code == 200:
                self.delete_file_id = None
                resp.success()
            else:
                resp.failure(f"Delete failed with status code {resp.status_code}")
