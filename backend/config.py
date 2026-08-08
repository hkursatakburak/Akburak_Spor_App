import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field

# Get absolute path to backend/.env file relative to this script
current_dir = os.path.dirname(os.path.abspath(__file__))
env_file_path = os.path.join(current_dir, ".env")

class Settings(BaseSettings):
    mongo_uri: str = Field(..., validation_alias="MONGO_URI")
    secret_key: str = Field("dev_secret_key_akb_sport_club_2026", validation_alias="SECRET_KEY")

    # Load configuration from the backend's specific .env file location
    model_config = SettingsConfigDict(
        env_file=env_file_path,
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
