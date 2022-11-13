from dataclasses import dataclass
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config.from_object("project.config.Config")
db = SQLAlchemy(app)


@dataclass
class User(db.Model):
    id: int = db.Column(db.Integer, primary_key=True)
    social_media_username: str = db.Column(db.String(120), unique=True, nullable=False)
    active: bool = db.Column(db.Boolean(), default=True, nullable=False)

    def __init__(self, social_media_username: str) -> None:
        self.social_media_username = social_media_username


@app.route("/")
def read_root():
    users = User.query.all()
    return jsonify(users)
