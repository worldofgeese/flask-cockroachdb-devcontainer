from project import app


def test_read_root():
    with app.test_client() as client:
        response = client.get("/")
        assert response.status_code == 200
